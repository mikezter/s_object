module SObject
  class Error < StandardError; end

  class SalesforceError < Error
    attr_reader :code
    def initialize(message, code = '')
      @code = code
      code = " (#{code})" unless code.empty?
      super(message + code)
    end
  end

  class QueryTooComplicatedError < SalesforceError; end

  class ObjectNotFoundError < SalesforceError; end

  class DuplicateValueError < SalesforceError; end

  class SessionError < SalesforceError; end

  class ValidationError < SalesforceError; end


  def self.error_class_for(message, code)
    error_class = case code
      when 'QUERY_TOO_COMPLICATED'             then QueryTooComplicatedError
      when 'NOT_FOUND'                         then ObjectNotFoundError
      when 'DUPLICATE_VALUE'                   then DuplicateValueError
      when 'INVALID_SESSION_ID'                then SessionError
      when 'FIELD_CUSTOM_VALIDATION_EXCEPTION' then ValidationError
      else                                          SalesforceError
    end

    return error_class.new(message, code)
  end

end