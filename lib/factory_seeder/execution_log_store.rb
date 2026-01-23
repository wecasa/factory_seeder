# frozen_string_literal: true

module FactorySeeder
  # Temporary in-memory storage for execution logs
  # Used to implement PRG pattern without session overflow
  class ExecutionLogStore
    EXPIRY_TIME = 300 # 5 minutes

    class << self
      def store(logs, flash_type: nil, flash_message: nil)
        cleanup_expired
        id = SecureRandom.hex(8)
        storage[id] = {
          logs: logs,
          flash_type: flash_type,
          flash_message: flash_message,
          created_at: Time.now
        }
        id
      end

      def retrieve(id)
        return nil if id.blank?

        cleanup_expired
        data = storage.delete(id)
        return nil unless data

        data
      end

      def clear
        @storage = {}
      end

      private

      def storage
        @storage ||= {}
      end

      def cleanup_expired
        cutoff = Time.now - EXPIRY_TIME
        storage.delete_if { |_id, data| data[:created_at] < cutoff }
      end
    end
  end
end
