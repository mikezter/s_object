module SObject
  Error = Class.new StandardError

  class CurlError < Error; end

  class SalesforceError < Error
    attr_reader :code
    def initialize(message, code = '')
      @code = code
      code = " (#{code})" unless code.empty?
      super(message + code)
    end
  end

  QueryTooComplicatedError = Class.new SalesforceError
  ObjectNotFoundError      = Class.new SalesforceError
  DuplicateValueError      = Class.new SalesforceError
  SessionError             = Class.new SalesforceError
  ValidationError          = Class.new SalesforceError
  InvalidFieldError        = Class.new SalesforceError
  InsertUpdateActivate     = Class.new SalesforceError

  def self.error_class_for(message, code)
    error_class = case code
      when 'QUERY_TOO_COMPLICATED'                 then QueryTooComplicatedError
      when 'NOT_FOUND'                             then ObjectNotFoundError
      when 'DUPLICATE_VALUE'                       then DuplicateValueError
      when 'INVALID_SESSION_ID'                    then SessionError
      when 'FIELD_CUSTOM_VALIDATION_EXCEPTION'     then ValidationError
      when 'INVALID_FIELD'                         then InvalidFieldError
      when 'CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY'  then InsertUpdateActivate
      else                                         SalesforceError
    end

    return error_class.new(message, code)
  end

end
