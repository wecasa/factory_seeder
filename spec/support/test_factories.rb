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
    fs_hostile: proc { |f| f.factory(:fs_hostile, class: 'TestModels::Hostile') },
    fs_ghost: proc { |f| f.factory(:fs_ghost, class: 'TestModels::Ghost') },
    fs_value: proc { |f| f.factory(:fs_value, class: 'TestModels::Value') { name { 'v' } } },
    fs_associated: proc { |f| f.factory(:fs_associated, class: 'TestModels::WithAssociation') },
    fs_odd_labels: proc { |f| f.factory(:fs_odd_labels, class: 'TestModels::OddLabels') },
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
