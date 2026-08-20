# frozen_string_literal: true

module FactorySeeder
  class RecordTracker
    STORAGE_KEY = :factory_seeder_tracked_records
    CHAIN_KEY = :factory_seeder_tracked_records_chain
    LOGGED_KEY = :factory_seeder_tracked_records_logged
    LABEL_METHODS = %i[name title label email reference slug].freeze
    LABEL_TYPES = [String, Symbol, Numeric].freeze
    INSTALL_MUTEX = Mutex.new

    class << self
      def install!
        INSTALL_MUTEX.synchronize do
          next true if callback_registered?

          register_callback
          true
        end
      end

      def installed?
        callback_registered?
      end

      def capture(into = [])
        install!
        previous = store
        enclosing = chain
        # An array already open further up must not receive its own entries twice.
        reentrant = enclosing.any? { |collected| collected.equal?(into) }

        self.chain = enclosing + [into]
        self.store = into
        self.logged_count = 0 if previous.nil?

        yield
      ensure
        self.chain = enclosing
        self.store = previous
        previous.concat(into) unless previous.nil? || reentrant
      end

      def track(record)
        current = store
        return record if current.nil? || !persisted?(record)

        entry = entry_for(record)
        current << entry
        log_entry(entry)
        record
      rescue StandardError
        record
      end

      def entry_for(record)
        {
          'model' => model_name_for(record),
          'id' => safe_send(record, :id),
          'label' => label_for(record)
        }
      end

      def summarize(entries)
        grouped = normalize(entries).group_by { |entry| entry['model'] }
        summaries = grouped.map do |model, model_entries|
          {
            'model' => model.to_s,
            'count' => model_entries.count,
            'ids' => model_entries.filter_map { |entry| entry['id'] }
          }
        end

        summaries.sort_by { |summary| [-summary['count'], summary['model']] }
      end

      def describe(entries)
        describe_summaries(summarize(entries))
      end

      def describe_summaries(summaries)
        return 'no record created' if summaries.empty?

        total = summaries.sum { |summary| summary['count'] }
        details = summaries.map { |summary| "#{summary['model']}: #{summary['count']}" }.join(', ')
        "#{total} record#{'s' unless total == 1} created (#{details})"
      end

      def format_entry(entry)
        parts = [entry['model'].to_s]
        parts << "##{entry['id']}" if entry['id']
        parts << "(#{entry['label']})" if entry['label']
        parts.join(' ')
      end

      def log_summary(entries)
        summaries = summarize(entries)
        FactorySeeder.log_info("📊 #{describe_summaries(summaries)}",
                               models: summaries.to_h { |summary| [summary['model'], summary['count']] })
      end

      private

      def register_callback
        FactoryBot.define do
          after(:create) do |record, _evaluator|
            FactorySeeder::RecordTracker.track(record)
          end
        end

        callbacks = registered_callbacks
        @callback = callbacks&.last
        @registered_blindly = callbacks.nil?
      end

      def callback_registered?
        callbacks = registered_callbacks
        # Without introspection -- which factory_bot exposes from 6.0, the floor
        # this gem requires -- assume a single registration is still in place
        # rather than risk stacking duplicates that would count every record twice.
        return !@callback.nil? || @registered_blindly == true if callbacks.nil?

        !@callback.nil? && callbacks.include?(@callback)
      end

      # factory_bot exposes its global callbacks through Internal from 6.0 onwards.
      def registered_callbacks
        return nil unless defined?(FactoryBot::Internal) && FactoryBot::Internal.respond_to?(:callbacks)

        FactoryBot::Internal.callbacks
      rescue StandardError
        nil
      end

      def chain
        Thread.current.thread_variable_get(CHAIN_KEY) || []
      end

      def chain=(value)
        Thread.current.thread_variable_set(CHAIN_KEY, value)
      end

      def store
        Thread.current.thread_variable_get(STORAGE_KEY)
      end

      def store=(value)
        Thread.current.thread_variable_set(STORAGE_KEY, value)
      end

      def logged_count
        Thread.current.thread_variable_get(LOGGED_KEY) || 0
      end

      def logged_count=(value)
        Thread.current.thread_variable_set(LOGGED_KEY, value)
      end

      def persisted?(record)
        return true unless record.respond_to?(:persisted?)

        record.persisted?
      rescue StandardError
        true
      end

      def log_entry(entry)
        limit = FactorySeeder.configuration.log_records_limit
        return if !limit.nil? && limit.to_i <= 0

        position = logged_count + 1
        self.logged_count = position

        if limit.nil? || position <= limit
          log_created(entry)
        elsif position == limit + 1
          FactorySeeder.log_info("… #{limit} records logged individually, further creations are only counted")
        end
      end

      def log_created(entry)
        FactorySeeder.log("🗃️  Created #{format_entry(entry)}", level: :success,
                                                                model: entry['model'], record_id: entry['id'])
      end

      def normalize(entries)
        case entries
        when nil then []
        when Array then entries
        else [entries]
        end
      end

      def model_name_for(record)
        record.class.name || record.class.to_s
      rescue StandardError
        'Unknown'
      end

      def label_for(record)
        LABEL_METHODS.each do |method_name|
          next if association?(record, method_name)
          next unless responds_to?(record, method_name)

          value = safe_send(record, method_name)
          next unless LABEL_TYPES.any? { |type| value.is_a?(type) }

          text = value.to_s
          next if text.strip.empty?

          return text
        end

        nil
      end

      def association?(record, name)
        klass = record.class
        return false unless klass.respond_to?(:reflect_on_association)

        !klass.reflect_on_association(name).nil?
      rescue StandardError
        false
      end

      def responds_to?(record, method_name)
        record.respond_to?(method_name)
      rescue StandardError
        false
      end

      def safe_send(record, method_name)
        return nil unless responds_to?(record, method_name)

        record.public_send(method_name)
      rescue StandardError
        nil
      end
    end
  end
end
