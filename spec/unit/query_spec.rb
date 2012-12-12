# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Query do
    context 'initialization' do
      it 'with an object type' do
        expect{Query.new 'Account' }.to_not raise_error ArgumentError
      end

      it 'raises error without object type' do
        expect{ Query.new }.to raise_error ArgumentError
      end

      it 'only accepts strings as object type' do
        expect{ Query.new 12345 }.to raise_error ArgumentError
      end
    end

    before :each do
      @query = Query.new 'Account', :fields => %w(lastName, FirstName)
    end
    DUMMY_RECORDS = [1, 2, 3]

    context 'fields' do
      it 'is an array' do
        @query.fields.should be_kind_of(Array)
      end

      it 'contains all downcased strings' do
        @query.fields.join.should_not match(/[A-Z]/)
      end

      it 'always contains the id field' do
        @query.fields.should include('id')
      end
    end

    it '#next_query' do
      @query.stub(:next_records_url).and_return 'wwww.foo-bar.com/next_record'

      Query.should_receive(:new).once
      @query.next_query
    end

    context '#each' do
      it 'more? = false' do
        @query.stub(:more?).and_return false
        @query.stub(:record_instances).and_return DUMMY_RECORDS

        expect { |x| @query.each(&x)}.to yield_successive_args(1, 2, 3)
      end

      it 'more? = true' do
        @query.stub(:more?).and_return true
        @query.stub(:record_instances).and_return DUMMY_RECORDS
        @query.stub(:next_query).and_return [4, 5]

        expect { |x| @query.each(&x)}.to yield_successive_args(1, 2, 3, 4, 5)
      end
    end

    it '#done?' do
      @query.should_receive(:data).and_return({ "done" => true })
      @query.done?.should be true
    end

    it 'more?' do
      @query.stub(:done?).and_return false
      @query.more?.should be true
    end

    it '#size' do
      @query.should_receive(:data).and_return({ "records" => mock(:size => 42) })
      @query.size.should be 42
    end

    it '#total_size' do
      @query.should_receive(:data).and_return({ "totalSize" => 13 })
      @query.total_size.should be 13
    end

    it '#data' do
      @query.stub(:url).and_return 'www.foo-bar.com'
      @query.stub(:params).and_return {}
      Request.should_receive(:run).with(@query.url, :params => @query.params).once.and_return 'data'

      @query.data.should eq 'data'
    end

    it '#records' do
      @query.should_receive(:data).and_return({ "records" => DUMMY_RECORDS })
      @query.records.should eq DUMMY_RECORDS
    end

    it '#record_instances' do
      @query.should_receive(:records).and_return DUMMY_RECORDS

      @query.record_class.should_receive(:new).exactly(DUMMY_RECORDS.size).times
      @query.record_instances
    end

    it '#next_records_url' do
      Authorization.stub(:instance_url).and_return 'www.foo-bar.com'
      @query.should_receive(:data).and_return({ "nextRecordsUrl" => '/next_record' })
      @query.next_records_url.should eq 'www.foo-bar.com/next_record'
    end

    it '#record_class' do
      Factory.should_receive(:get).with(@query.type).once
      @query.record_class
    end

    it '#url' do
      Authorization.stub(:service_url).and_return 'www.foo-bar.com'
      @query.url.should eq 'www.foo-bar.com/query'
    end

    it { @query.params.should be_kind_of Hash }

    it '#wheres' do
      @query.wheres.should eq ""
      query = Query.new 'Account', :where => [ "test IS NOT NULL", "1 = 1" ]
      query.wheres.should eq "WHERE test IS NOT NULL AND 1 = 1"
    end

  end
end

