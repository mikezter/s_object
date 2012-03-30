module SObject
  class Factory

    attr_accessor :type

    def initialize(type)
      raise ArgumentError.new("Type required") unless type
      @type = type
    end

    def self.get(type)
      new(type).get
    end

    def get
      create_class unless SObject.const_defined?(normalized_type)
      return SObject.const_get(normalized_type)
    end

  private

    def normalized_type
      @type.sub(/__c$/, '')
    end

    def create_class
      SObject.module_eval <<-RB
        class #{normalized_type} < SObject::Base
          def self.type; '#{type}'; end
        end
      RB
    end

  end
end