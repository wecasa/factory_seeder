# frozen_string_literal: true

module FactorySeeder
  module AssetHelper
    def self.javascript_path(filename)
      # Dans une gem, on peut servir les assets directement depuis le dossier app/assets
      File.join(File.dirname(__FILE__), '..', '..', 'app', 'assets', 'javascript', filename)
    end

    def self.stylesheet_path(filename)
      File.join(File.dirname(__FILE__), '..', '..', 'app', 'assets', 'stylesheets', filename)
    end

    def self.asset_content(filename)
      path = javascript_path(filename)
      File.read(path) if File.exist?(path)
    end

    def self.css_content(filename)
      path = stylesheet_path(filename)
      File.read(path) if File.exist?(path)
    end

    def self.available_assets
      js_dir = File.join(File.dirname(__FILE__), '..', '..', 'app', 'assets', 'javascript')
      Dir.glob(File.join(js_dir, '*.js')).map { |f| File.basename(f) }
    end

    def self.available_stylesheets
      css_dir = File.join(File.dirname(__FILE__), '..', '..', 'app', 'assets', 'stylesheets')
      Dir.glob(File.join(css_dir, '*.css')).map { |f| File.basename(f) }
    end
  end
end
