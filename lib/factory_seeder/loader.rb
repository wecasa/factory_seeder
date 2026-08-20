# frozen_string_literal: true

require 'zeitwerk'

module FactorySeeder
  class Loader
    class << self
      def setup
        return if @loader

        @loader = Zeitwerk::Loader.new
        @loader.inflector.inflect('cli' => 'CLI')
        @loader.push_dir(File.expand_path(__dir__), namespace: FactorySeeder)
        @loader.ignore("#{__dir__}/version.rb")
        @loader.ignore("#{__dir__}/record_tracker.rb")
        @loader.enable_reloading
        @loader.setup
      end

      def reload!
        return unless @loader&.reloading_enabled?

        @loader.reload
      end
    end
  end
end
