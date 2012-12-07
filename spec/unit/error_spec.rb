require 'spec_helper'

module SObject
  describe Error do
    context '.error_class_for' do

      ERROR_CLASSES = {'QUERY_TOO_COMPLICATED' => QueryTooComplicatedError,
                       'NOT_FOUND' => ObjectNotFoundError,
                       'DUPLICATE_VALUE' => DuplicateValueError,
                       'INVALID_SESSION_ID' => SessionError,
                       'FIELD_CUSTOM_VALIDATION_EXCEPTION' => ValidationError,
                       'OTHER_ERROR' => SalesforceError }

      ERROR_CLASSES.each do |error_code,error_class|
        it "#{error_code} should end up in #{error_class}" do
          SObject.error_class_for('xyz', error_code).should be_kind_of error_class
        end
      end

    end
  end
end
