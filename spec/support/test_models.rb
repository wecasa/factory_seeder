# frozen_string_literal: true

# Plain Ruby stand-ins for ActiveRecord models: the gem is tested without a
# database, so "persisting" only means being handed an id.
module TestModels
  Reflection = Struct.new(:name, :macro)

  class Base
    attr_accessor :id

    class << self
      attr_accessor :sequence

      def next_id
        self.sequence = (sequence || 0) + 1
      end

      def reflect_on_all_associations
        []
      end

      def reflect_on_association(name)
        reflect_on_all_associations.find { |reflection| reflection.name.to_s == name.to_s }
      end
    end

    def save!
      @id = self.class.next_id
      self
    end

    def persisted?
      !@id.nil?
    end

    def attributes
      instance_variables.to_h { |ivar| [ivar.to_s.delete('@'), instance_variable_get(ivar)] }
    end
  end

  class Author < Base
    attr_accessor :name
  end

  class Article < Base
    attr_accessor :title, :author

    def self.reflect_on_all_associations
      [Reflection.new(:author, :belongs_to)]
    end
  end

  # Declares a has_many, which must be filtered out of the attributes handed to
  # FactoryBot rather than assigned.
  class Blog < Base
    attr_accessor :title

    def self.reflect_on_all_associations
      [Reflection.new(:articles, :has_many)]
    end
  end

  MODELS = [Author, Article, Blog].freeze

  def self.reset!
    MODELS.each { |klass| klass.sequence = 0 }
  end

  module Helpers
    def create_entry(model:, id: nil, label: nil)
      { 'model' => model, 'id' => id, 'label' => label }
    end
  end
end
