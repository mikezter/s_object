# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Base do
    context 'initialization' do
      it 'has no fields' do
        expect {Base.new}.to raise_error NoMethodError
      end

      INSTANCE_URL = 'http://example.org/abcdefg/'
      ORIGN_INIT_FIELDS = { 'Id' => 123, "attributes" => { "type" => "Account", "url" => 'xyz' } }

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

    context 'instance methods' do
      before :each do
        Authorization.stub(:service_url).and_return INSTANCE_URL
        Authorization.stub(:instance_url).and_return INSTANCE_URL
        Base.stub(:field_type).and_return "string"


        @account = SObject::Factory.get('Account').new ORIGN_INIT_FIELDS
        @cleaned_fields = { 'id' => 123 }
      end

      it '#fields' do
        @account.fields.should eq(@cleaned_fields)
      end

      it '#update_fields' do
        additional_data = {"hallo" => "Welt"}
        @account.update_fields(additional_data)
        @account.fields.should eq(@cleaned_fields.merge additional_data)
      end

      it '#type' do
        @account.type.should eq "Account"
      end


    end
  end
end
