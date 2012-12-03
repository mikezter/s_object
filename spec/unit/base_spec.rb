# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Base do
    context 'initialization' do
      it 'has no fields' do
        expect {Base.new}.to raise_error NoMethodError
      end

      INSTANCE_URL = 'http://example.org/abcdefg/'

      it 'has fields' do
        # TODO How the Heck is this class instanced?
        # Authorization.stub(:instance_url).and_return INSTANCE_URL
        # Authorization.stub(:service_url).and_return INSTANCE_URL
        # Authorization.stub(:access_token).and_return "{'test': 'xyz'}"
        # account = SObject::Factory.get('Account').new
        # account.instance_variable(:url).should eq "http://example.org/abcdefg//services/data/v22.0/sobjects/Account"
        # account.instance_variable(:type).should eq nil
        expect{SObject::Factory.get('Account').new}.not_to raise_error Error
      end
    end
  end
end
