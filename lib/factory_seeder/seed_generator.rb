# frozen_string_literal: true

module FactorySeeder
  class SeedGenerator
    def initialize
      @generated_records = []
      @defined_seeds = {}
    end

    def preview(factory_name, count = 1, traits = [], attributes = {})
      traits = traits.map(&:to_sym)
      filtered_attributes = filter_association_attributes(factory_name, attributes)

      preview_data = []
      count.times do |i|
        begin
          # Build without saving
          record = FactoryBot.build(factory_name, *traits, filtered_attributes)
        rescue NoMethodError => e
          # Check if this is the specific error about calling a method on CollectionProxy
          raise unless e.message.include?('CollectionProxy') && e.message.include?('undefined method')

          method_name = e.message.match(/undefined method `(\w+)'/)&.[](1)
          # Try to identify which attribute might be causing the issue
          problematic_attrs = attributes.select { |k, v| v.to_s == method_name || k.to_s == method_name }
          if problematic_attrs.any?
            raise NoMethodError,
                  "#{e.message}. This might be caused by passing '#{problematic_attrs.keys.first}' as an attribute. Collection associations (has_many, has_and_belongs_to_many) cannot be set directly via attributes."
          else
            raise NoMethodError,
                  "#{e.message}. This might be caused by an attribute that matches an association name. Try removing association-related attributes from your attributes hash."
          end
        end

        preview_data << {
          index: i + 1,
          attributes: record.attributes,
          associations: extract_associations(record)
        }
      rescue StandardError => e
        preview_data << {
          index: i + 1,
          error: e.message
        }
      end

      {
        factory: factory_name,
        count: count,
        traits: traits,
        attributes: attributes,
        preview: preview_data
      }
    end

    def generate(factory_name, count = 1, traits = [], attributes = {}, strategy = 'create')
      traits = traits.map(&:to_sym)
      filtered_attributes = filter_association_attributes(factory_name, attributes)

      FactorySeeder.clear_execution_logs!
      FactorySeeder.log_info("Starting #{factory_name} generation", count: count, traits: traits, strategy: strategy)

      generated_count = 0
      errors = []

      count.times do |i|
        begin
          if strategy == 'create'
            record = FactoryBot.create(factory_name, *traits, filtered_attributes)
          else
            record = FactoryBot.build(factory_name, *traits, filtered_attributes)
            record.save! if record.respond_to?(:save!)
          end
        rescue NoMethodError => e
          # Check if this is the specific error about calling a method on CollectionProxy
          raise unless e.message.include?('CollectionProxy') && e.message.include?('undefined method')

          method_name = e.message.match(/undefined method `(\w+)'/)&.[](1)
          # Try to identify which attribute might be causing the issue
          problematic_attrs = attributes.select { |k, v| v.to_s == method_name || k.to_s == method_name }
          if problematic_attrs.any?
            raise NoMethodError,
                  "#{e.message}. This might be caused by passing '#{problematic_attrs.keys.first}' as an attribute. Collection associations (has_many, has_and_belongs_to_many) cannot be set directly via attributes."
          else
            raise NoMethodError,
                  "#{e.message}. This might be caused by an attribute that matches an association name. Try removing association-related attributes from your attributes hash."
          end
        end

        @generated_records << {
          factory: factory_name,
          record: record,
          traits: traits,
          attributes: attributes,
          strategy: strategy
        }

        generated_count += 1

        FactorySeeder.log("✅ Generated #{factory_name} ##{i + 1}", level: :success)
        puts "✅ Generated #{factory_name} ##{i + 1}" if FactorySeeder.configuration.verbose
      rescue StandardError => e
        error_msg = "Failed to generate #{factory_name} ##{i + 1}: #{e.message}"
        errors << error_msg
        FactorySeeder.log(error_msg, level: :error)
        puts "❌ #{error_msg}" if FactorySeeder.configuration.verbose
      end

      FactorySeeder.log_info('Completed generation', generated_count: generated_count, errors: errors.count)
      logs = FactorySeeder.normalized_logs(FactorySeeder.execution_logs)
      FactorySeeder.clear_execution_logs!

      {
        factory: factory_name,
        generated_records: @generated_records,
        count: generated_count,
        requested_count: count,
        traits: traits,
        attributes: attributes,
        strategy: strategy,
        errors: errors,
        logs: logs
      }
    end

    def summary
      return 'No records generated' if @generated_records.empty?

      summary = "📊 Generation Summary:\n"
      summary += "#{'=' * 50}\n"

      by_factory = @generated_records.group_by { |r| r[:factory] }

      by_factory.each do |factory_name, records|
        summary += "\n🏭 #{factory_name}: #{records.count} records\n"
        records.each_with_index do |record, index|
          summary += "   #{index + 1}. Strategy: #{record[:strategy]}"
          summary += ", Traits: #{record[:traits].join(', ')}" if record[:traits].any?
          summary += ", Attributes: #{record[:attributes]}" if record[:attributes].any?
          summary += "\n"
        end
      end

      summary
    end

    def define_seed(name, &block)
      @defined_seeds[name.to_sym] = block
    end

    def run_seed(name)
      seed_name = name.to_sym
      unless @defined_seeds.key?(seed_name)
        raise "Seed '#{name}' not found. Available seeds: #{@defined_seeds.keys.join(', ')}"
      end

      @defined_seeds[seed_name].call(self)
    end

    def list_seeds
      @defined_seeds.keys
    end

    def has_seed?(name)
      @defined_seeds.key?(name.to_sym)
    end

    def run_all_seeds
      puts '🌱 Running all defined seeds...'
      @defined_seeds.each do |name, block|
        puts "\n--- Running seed: #{name} ---"
        block.call(self)
      end
      puts "\n✅ All seeds completed successfully"
    end

    private

    def filter_association_attributes(factory_name, attributes)
      return attributes if attributes.empty?

      begin
        # Get the factory
        factory = FactoryBot.factories.find { |f| f.name.to_s == factory_name.to_s }
        return attributes unless factory

        # Get associations from factory definition
        factory_associations = []
        factory.definition.declarations.each do |declaration|
          factory_associations << declaration.name.to_s if declaration.is_a?(FactoryBot::Declaration::Association)
        end

        # Get the model class from the factory
        model_class = factory.build_class
        model_associations = []

        if model_class.respond_to?(:reflect_on_all_associations)
          # Get all has_many and has_and_belongs_to_many associations from the model
          model_associations = model_class.reflect_on_all_associations.select do |assoc|
            %i[has_many has_and_belongs_to_many].include?(assoc.macro)
          end.map { |assoc| assoc.name.to_s }
        end

        # Combine factory and model associations
        all_collection_associations = (factory_associations + model_associations).uniq

        # Get all associations (including belongs_to and has_one) for additional safety
        all_associations = []
        if model_class.respond_to?(:reflect_on_all_associations)
          all_associations = model_class.reflect_on_all_associations.map { |assoc| assoc.name.to_s }
        end
        all_associations = (all_associations + factory_associations).uniq

        # Filter out attributes that match collection associations
        filtered = attributes.dup
        all_collection_associations.each do |assoc_name|
          filtered.delete(assoc_name.to_sym)
          filtered.delete(assoc_name.to_s)
        end

        # Additional safety: filter out any attribute whose value is a symbol
        # and whose key matches an association name (to prevent method calls on associations)
        filtered_before_symbol_check = filtered.dup
        filtered.delete_if do |key, value|
          key_str = key.to_s
          # If the value is a symbol and the key matches an association name,
          # FactoryBot might try to call that symbol as a method on the association
          if value.is_a?(Symbol) && all_associations.include?(key_str)
            if FactorySeeder.configuration.verbose
              puts "🔍 Filtering attribute '#{key_str}' (value: #{value}) - matches association name"
            end
            true
          # Also filter if key looks like an association name (plural, ends with _ids, etc.)
          elsif value.is_a?(Symbol) && (
            key_str.end_with?('_ids') ||
            (key_str.pluralize == key_str && key_str.singularize != key_str)
          )
            # Double-check if it's actually an association
            if model_class.respond_to?(:reflect_on_all_associations)
              association = model_class.reflect_on_association(key_str.singularize.to_sym) ||
                            model_class.reflect_on_association(key_str.to_sym)
              if !association.nil?
                if FactorySeeder.configuration.verbose
                  puts "🔍 Filtering attribute '#{key_str}' (value: #{value}) - detected as association"
                end
                true
              else
                false
              end
            else
              false
            end
          else
            false
          end
        end

        if FactorySeeder.configuration.verbose && filtered_before_symbol_check != filtered
          removed = filtered_before_symbol_check.keys - filtered.keys
          puts "🔍 Filtered out #{removed.count} association-related attributes: #{removed.join(', ')}" if removed.any?
        end

        filtered
      rescue StandardError => e
        # If we can't determine associations, try a more aggressive filter
        # Filter out any attribute that might be problematic
        filtered = attributes.dup

        # Remove any attribute whose value is a symbol (which FactoryBot might try to call as a method)
        # but only if we're not sure it's safe
        filtered.delete_if do |key, value|
          # If value is a symbol and key looks like it could be an association name
          value.is_a?(Symbol) && (
            key.to_s.end_with?('_ids') ||
            key.to_s.pluralize == key.to_s ||
            key.to_s.singularize != key.to_s
          )
        end

        if FactorySeeder.configuration.verbose
          puts "⚠️  Warning: Could not fully filter association attributes: #{e.message}"
        end
        filtered
      end
    end

    def extract_associations(record)
      associations = {}

      record.class.reflect_on_all_associations.each do |association|
        if association.macro == :belongs_to
          associated_record = record.send(association.name)
          associations[association.name] = associated_record&.id if associated_record
        elsif association.macro == :has_many
          associated_records = record.send(association.name)
          associations[association.name] = associated_records.map(&:id) if associated_records.any?
        end
      rescue StandardError => e
        associations[association.name] = "Error: #{e.message}"
      end

      associations
    end
  end
end
