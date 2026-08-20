# frozen_string_literal: true

module FactorySeeder
  class CustomSeedsController < ApplicationController
    def index
      @seeds = FactorySeeder.list_custom_seeds
    end

    def show
      @seed = FactorySeeder.find_custom_seed(params[:name])
      if @seed.nil?
        flash[:error] = "Seed '#{params[:name]}' not found"
        redirect_to custom_seeds_path
        return
      end
      @seed_name = @seed.name
      @execution_logs = []

      # Retrieve logs from temporary storage if available (PRG pattern)
      if params[:log_id].present?
        stored = ExecutionLogStore.retrieve(params[:log_id])
        if stored
          @execution_logs = stored[:logs] || []
          flash.now[stored[:flash_type]] = stored[:flash_message] if stored[:flash_type]
        end
      end
    end

    def create
      seed_name = params[:name]
      seed = FactorySeeder.find_custom_seed(seed_name)

      if seed.nil?
        flash[:error] = "Seed '#{seed_name}' not found"
        redirect_to custom_seeds_path
        return
      end

      attributes = safe_attributes_params
      result = FactorySeeder.run_custom_seed(seed_name, **attributes)
      logs = result[:logs] || []

      flash_type = result[:success] ? :success : :error
      log_id = ExecutionLogStore.store(logs, flash_type: flash_type, flash_message: result[:message])

      redirect_to custom_seed_path(seed_name, log_id: log_id)
    end

    def new
      # For creating new seeds via web interface (future feature)
      @seed = nil
    end

    def edit
      @seed = FactorySeeder.find_custom_seed(params[:name])
      return unless @seed.nil?

      flash[:error] = "Seed '#{params[:name]}' not found"
      redirect_to custom_seeds_path
      nil
    end

    def update
      # For updating existing seeds (future feature)
      seed_name = params[:name]
      # Implementation would go here
      redirect_to custom_seed_path(seed_name)
    end

    def destroy
      # For deleting seeds (future feature)
      params[:name]
      # Implementation would go here
      redirect_to custom_seeds_path
    end

    private

    def safe_attributes_params
      return {} unless params.key?(:attributes)

      raw_attributes = params.require(:attributes).permit!.to_h
      seed = FactorySeeder.find_custom_seed(params[:name])
      return raw_attributes.transform_keys(&:to_sym) unless seed

      seed.coerce_parameters(raw_attributes)
    end
  end
end
