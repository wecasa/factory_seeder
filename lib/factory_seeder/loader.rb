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
        @loader.enable_reloading
        @loader.setup
      end

      def reload!
        return unless @loader && @loader.reloading_enabled?

        @loader.reload
      end
    end
  end
end
