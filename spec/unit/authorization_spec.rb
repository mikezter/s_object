# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Authorization do
    subject { Authorization }
    let(:access_token_url) { 'https://test.salesforce.com/services/oauth2/token' }
    let(:config) { { 'access_token_url' => access_token_url } }

    it '.login' do
      credentials =  { 'access_token' => 'token', 'instance_url' => 'www.foo.com'}
      subject.stub(:credentials).and_return credentials
      subject.login(config).should eq credentials
    end

    it '.access_token' do
      access_token = 'test_token123'
      subject.stub(:credentials).and_return( { 'access_token' => access_token } )
      subject.access_token.should eq access_token
    end

    it '.instance_url' do
      url = 'www.foo-bar.com/instance'
      subject.stub(:credentials).and_return( { 'instance_url' => url } )
      subject.instance_url.should eq url
    end

    it '.service_path' do
      subject.service_path.should eq "/services/data/#{SObject::SF_API_VERSION}"
    end

    it '.service_url' do
      subject.stub(:instance_url).and_return 'www.foo-bar.com'
      subject.stub(:service_path).and_return '/service_path'

      subject.service_url.should eq 'www.foo-bar.com/service_path'
    end

    it '.reset' do
      subject.stub(:request_credentials).and_return 'credentials'
      subject.credentials

      subject.stub(:request_credentials)
      expect { subject.reset }.to change{ subject.credentials }
    end

    context '.headers' do
      before :each do
        subject.stub(:access_token).and_return 'test_token123'
        @headers = subject.headers
      end

      ['Authorization', 'Content-Type', 'Accept', 'X-PrettyPrint'].each do |key|
        it { @headers.should have_key key }
      end
    end

    it '.credentials' do
      credentials =  { 'access_token' => 'token', 'instance_url' => 'www.foo.com'}
      subject.stub(:request_credentials).and_return credentials
      subject.credentials.should eq credentials
    end

    context 'private methods' do
      context '.request_credentials' do
        let(:json_string) {
          '{"desc":{"someKey":"someValue","anotherKey":"value"}}'
        }
        let(:response_hash) { JSON.parse json_string }

        it 'successful request' do
          Typhoeus::Request.should_receive(:post).
            with(access_token_url, params: config).once.
            and_return mock(success?: true, body: json_string)

          subject.send(:request_credentials).should eq response_hash

        end

        it 'not successful request' do
          Typhoeus::Request.should_receive(:post).
            with(access_token_url, :params => config).once.
            and_return mock(success?: false)
          expect { subject.send(:request_credentials) }.to raise_error
        end
      end

    end

  end
end
