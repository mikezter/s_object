require 'spec_helper'

module SObject
  describe Request do
    DUMMY_URL = 'http://localhost/'
    ERROR_JSON = %q({'errorCode': 'ERROR_CODE', 'message': 'Error message here.'})

    it 'gets initialized with an url' do
      lambda{ Request.new }.should raise_error(ArgumentError)
    end

    context 'instance' do

      before :each do
        @request = Request.new DUMMY_URL
      end

      context 'defaults' do

        it 'is an empty body' do
          @request.body.should eq('')
        end

        it 'is the GET method' do
          @request.method.should eq(:get)
        end

        it 'is an empty params hash' do
          @request.params.should eq({})
        end

      end

      context 'run' do

        it 'raises an error on failing requests' do
          error_response = mock(:success? => false, :body => ERROR_JSON)
          Typhoeus::Request.should_receive(:run).and_return error_response

          lambda{ @request.run }.should raise_error(SalesforceError)
        end
      end
      it 'uses Authorization headers' do
        dummy = { :foo => 'bar' }
        Authorization.should_receive(:headers).and_return dummy
        @request.headers.should eq dummy
      end
    end

  end

end

