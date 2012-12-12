# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Base do
    context 'initialization' do
      it 'has no fields' do
        Authorization.stub(:service_url).and_return INSTANCE_URL
        Base.stub(:type).and_return 'type'

        expect {Base.new}.to_not raise_error
      end

      it 'has no type' do
        Authorization.stub(:service_url).and_return INSTANCE_URL
        expect {Base.new}.to raise_error NotImplementedError
      end

      INSTANCE_URL = 'http://example.org/abcdefg/'
      ORIGIN_INIT_FIELDS = { 'Id' => 123, "attributes" => { "type" => "Account",
                                                            "url" => 'xyz'} }

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


        @account = SObject::Factory.get('Account').new ORIGIN_INIT_FIELDS
        @cleaned_fields = { 'id' => 123 }
      end

      context '#method_missing' do
        subject { SObject::Factory.get('Account').new ORIGIN_INIT_FIELDS.dup.merge('test' => 'x')}
        before :each do
          subject.class.stub(:all_fields).and_return ORIGIN_INIT_FIELDS['attributes'].keys
        end

        it 'provides getter method' do
          subject.test.should eq 'x'
        end

        it 'provides setter method' do
          expect { subject.test = 'y'}.to change{subject.test}.from('x').to('y')
        end

        def stub_field_methods
          field_name = yield

          subject.stub(:fields).and_return({ field_name => field_name })
          subject.should_receive(:field_property).with(field_name, 'referenceTo').
            and_return(['Other'])
          subject.should_receive(:field_type).with(field_name).and_return 'reference'
        end

        context 'auto_resolves relationships' do
          ['other_tableid', 'other_tableid__c', 'other_table_lookup__c'].each do
            |field_name|
            it "auto-resolves relationship named #{field_name.gsub('other_table', '')}" do
              stub_field_methods { field_name }

              SObject::Factory.should_receive(:get).with('Other').once.
                and_return mock(:find => 'abc')
              subject.other_table.should eq 'abc'
            end
          end
        end

        it 'raises error for not resolvable method calls' do
          expect { subject.not_resolvable_method }.to raise_error NoMethodError
        end
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

      it '#id' do
        @account.id.should be 123
      end

      it '#reload!' do
        @account.class.should_receive(:find).once
        @account.reload!
      end

      context 'private methods' do
        context 'save_method' do
          it 'new_record? = true' do
            @account.stub(:new_record?).and_return true
            @account.send(:save_method).should eq :post
          end

          it 'new_record? = false' do
            @account.stub(:new_record?).and_return false
            @account.send(:save_method).should eq :patch
          end
        end

        it '#saveable_fields' do
          Base.stub(:field_exists?).and_return true
          Base.stub(:field_property).and_return true

          @account.send(:saveable_fields).should eq @cleaned_fields
        end

        it '#metadata' do
          Base.stub(:metadata).and_return 'Class Metadata'
          @account.send(:metadata).should eq 'Class Metadata'
        end

        it '#field_type' do
          Base.stub(:field_type).and_return 'Class Field Type'
          @account.send(:field_type, 'id').should eq 'Class Field Type'
        end

        it '#field_exists?' do
          Base.stub(:field_exists?).and_return true
          @account.send(:field_exists?, 'id').should be true
        end

        it '#field_property' do
          Base.stub(:field_property).and_return 'Class Field Property'
          @account.send(:field_property, 'id', 'updateable').should eq 'Class Field Property'
        end

        context '#to_datetime_string' do
          [Date.today, DateTime.now, Time.now].each do |date|
            it "type: #{date.class}" do
              @account.send(:to_sf_datetime_string, date).should eq date.strftime(SObject::SF_DATETIME_FORMAT)
            end
          end
        end
      end

      context 'salesforce communication' do
        before :each do
          Request.should_receive(:run).once.and_return({ "example_status" => "1" })
        end

        it '#delete' do
          @account.delete.should be true
        end

        it '#save' do
          @account.should_receive(:saveable_fields).once.and_return({})
          @account.save.should be true
        end
      end

      context 'class methods' do
        before :each do
          Base.stub(:type).and_return 'type'
        end

        it '.find' do
          Base.should_receive(:find_by_id).with(123).
            and_raise(QueryTooComplicatedError.new("error"))
          Base.should_receive(:find_throttled).with(123).once
          Base.find(123)
        end

        it '.find_by_id' do
          Authorization.stub(:service_url).and_return INSTANCE_URL

          Request.should_receive(:run).with("#{INSTANCE_URL}/sobjects/type/123").
            once.and_return({ 'response' => 'abc' })
          Base.find_by_id(123)
        end

        context '.find_fields_by_id' do
          it 'not found' do
            Query.should_receive(:new).and_return mock(:records => [])
            expect { Base.find_fields_by_id(123) }.to raise_error
          end

          it 'found' do
            Query.should_receive(:new).and_return mock(:records => [ { :id => 123 } ])
            Base.find_fields_by_id(123).should be_kind_of Hash
          end
        end

        it '.find_throttled' do
          Base.stub(:all_fields).and_return(1..80)

          Base.should_receive(:find_fields_by_id).exactly(4).times.
            and_return( { 'testhash' => 1 } )
          Base.find_throttled(123)
        end

        it '.metadata' do
          @metadata_hash = { 'type' => 'Account', 'fields' => [ { 'name' => 'Id'} ] }

          Request.should_receive(:run).and_return @metadata_hash
          Base.metadata.should eq({ 'type' => 'Account', 'fields' => [ { 'name' => 'id'} ] })
        end

        it '.count' do
          Base.stub(:query).and_return mock(:total_size => 42)
          Base.count.should eq 42
        end

        it '.first' do
          Base.stub(:query).and_return mock(:records => [ { 'Id' => 321} ])

          Base.should_receive(:find).with(321).once
          Base.first
        end

        it '.fields' do
          Base.stub(:all_fields).and_return ['Id', 'Other_Field']
          Base.fields.should eq ['Id', 'Other_Field']
        end

        it '.all_fields' do
          fields = [ { 'name' => 'Id' }, { 'name' => 'Id' }, { 'name' => 'First_Field' }]
          Base.stub(:metadata).and_return({ 'fields' => fields })

          Base.all_fields.should eq ['First_Field', 'Id']
        end

        it '.field_type' do
          Base.unstub(:field_type)

          Base.should_receive(:field_property).with('test_field', 'type').once
          Base.field_type('test_field')
        end

        context '.field_property' do
          it 'without field_metadata' do
            Base.stub(:field_metadata).and_return nil
            expect { Base.field_property('error_field', 'updateable') }.to raise_error
          end

          it 'with field_metadata' do
            Base.stub(:field_metadata).and_return({ 'updateable' => true })
            Base.field_property('field', 'updateable').should eq true
          end
        end

        it '.field_metadata' do
          fields = [ { 'name' => 'id' }, { 'name' => 'last_field' }, { 'name' => 'last_field' }]
          Base.stub(:metadata).and_return({ 'fields' => fields })

          Base.field_metadata("Last_Field").should eq fields.last
        end

        context '.field_exists' do
          it 'field_metadata is nil' do
            Base.stub(:field_metadata).and_return nil
            Base.field_exists?('field').should be false
          end

          it 'field_metadata is a hash' do
            Base.stub(:field_metadata).and_return( { 'fields' => [] } )
            Base.field_exists?('field').should be true
          end
        end

        it '.create' do
          account = SObject::Factory.get('Account').new ORIGIN_INIT_FIELDS
          Base.should_receive(:new).once.and_return account

          account.should_receive(:save).once
          Base.create
        end

        it '.type' do
          Base.unstub(:type)
          expect { Base.type }.to raise_error NotImplementedError
        end

        it '.query' do
          Query.should_receive(:new).once
          Base.send(:query)
        end
      end
    end
  end
end
