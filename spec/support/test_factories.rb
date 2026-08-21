# frozen_string_literal: true

# Registered under an fs_ prefix so they never clash with the fixture
# factories in spec/factories, which FactoryBot.reload picks up.
module TestFactories
  DEFINITIONS = {
    fs_author: proc { |f| f.factory(:fs_author, class: 'TestModels::Author') { name { 'Ada' } } },
    fs_article: proc { |f|
      f.factory(:fs_article, class: 'TestModels::Article') do
        title { 'Hello' }
        association :author, factory: :fs_author
      end
    },
    fs_blog: proc { |f| f.factory(:fs_blog, class: 'TestModels::Blog') { title { 'Blog' } } },
    fs_traited: proc { |f|
      f.factory(:fs_traited, class: 'TestModels::Author') do
        name { 'Ada' }
        trait(:famous) { name { 'Grace' } }
      end
    }
  }.freeze

  def self.define!
    missing = DEFINITIONS.reject { |name, _| FactoryBot.factories.registered?(name) }
    return if missing.empty?

    FactoryBot.define do
      missing.each_value { |definition| definition.call(self) }
    end
  end
end
