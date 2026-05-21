# frozen_string_literal: true

module FactorySeeder
  # Temporary storage for execution logs
  # Used to implement PRG pattern without session overflow
  #
  # Uses Rails.cache when available (works across processes) and falls back to
  # an in-memory Hash otherwise. The in-memory fallback only works when the
  # POST/GET cycle is served by the same Ruby process, which is fine for
  # single-process dev servers but breaks behind a multi-worker/multi-task
  # setup (Puma cluster, multiple ECS tasks).
  class ExecutionLogStore
    EXPIRY_TIME = 300 # 5 minutes
    CACHE_KEY_PREFIX = 'factory_seeder/execution_log_store'

    class << self
      def store(logs, flash_type: nil, flash_message: nil)
        id = SecureRandom.hex(8)
        data = {
          logs: logs,
          flash_type: flash_type,
          flash_message: flash_message,
          created_at: Time.now
        }
        write(id, data)
        id
      end

      def retrieve(id)
        return nil if id.nil? || id.to_s.empty?

        if rails_cache_available?
          key = cache_key(id)
          data = Rails.cache.read(key)
          Rails.cache.delete(key) if data
          data
        else
          cleanup_expired
          memory_storage.delete(id)
        end
      end

      def clear
        Rails.cache.delete_matched("#{CACHE_KEY_PREFIX}/*") if rails_cache_available?
        @memory_storage = {}
      end

      private

      def write(id, data)
        if rails_cache_available?
          Rails.cache.write(cache_key(id), data, expires_in: EXPIRY_TIME)
        else
          cleanup_expired
          memory_storage[id] = data
        end
      end

      def memory_storage
        @memory_storage ||= {}
      end

      def cleanup_expired
        cutoff = Time.now - EXPIRY_TIME
        memory_storage.delete_if { |_id, data| data[:created_at] < cutoff }
      end

      def rails_cache_available?
        defined?(Rails) && Rails.respond_to?(:cache) && Rails.cache
      end

      def cache_key(id)
        "#{CACHE_KEY_PREFIX}/#{id}"
      end
    end
  end
end
