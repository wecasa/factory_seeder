# frozen_string_literal: true

module FactorySeeder
  class FactoryController < ApplicationController
    def index
      @factories = FactorySeeder.scan_loaded_factories
    end

    def show
      @factory_name = params[:name]
      @factories = FactorySeeder.scan_loaded_factories
      @factory = @factories[@factory_name]
      @execution_logs = []
      @created_records = []

      # Retrieve logs from temporary storage if available (PRG pattern)
      if params[:log_id].present?
        stored = ExecutionLogStore.retrieve(params[:log_id])
        if stored
          @execution_logs = stored[:logs] || []
          @created_records = stored[:records] || []
          flash.now[stored[:flash_type]] = stored[:flash_message] if stored[:flash_type]
        end
      end

      return if @factory

      redirect_to root_path, alert: "Factory '#{@factory_name}' not found"
      nil
    end

    def generate
      factory_name = params[:name]
      count = (params[:count] || 1).to_i
      traits = parse_traits(params[:selected_traits])

      begin
        generator = SeedGenerator.new
        result = generator.generate(factory_name, count, traits, generate_params[:attributes].to_h.compact_blank)
        logs = result[:logs] || []
        records = result[:created_records] || []

        flash_type, flash_message = generation_flash(result, factory_name, records)
        log_id = ExecutionLogStore.store(logs, records: records, flash_type: flash_type,
                                               flash_message: flash_message)
      rescue StandardError => e
        log_id = ExecutionLogStore.store([], flash_type: :error, flash_message: "Error generating seeds: #{e.message}")
      end

      redirect_to factory_path(factory_name, log_id: log_id)
    end

    private

    def generation_flash(result, factory_name, records)
      return [:error, "Error generating seeds: #{result[:errors].join(', ')}"] if result[:errors].any?

      [:success, "Generated #{result[:count]} #{factory_name} — #{RecordTracker.describe(records)}"]
    end

    def parse_traits(traits_param)
      return [] if traits_param.blank?

      if traits_param.is_a?(String)
        traits_param.split(',').map(&:strip).reject(&:blank?)
      else
        traits_param
      end
    end

    def generate_params
      params.permit(:name, :count, :selected_traits, attributes: {})
    end
  end
end
