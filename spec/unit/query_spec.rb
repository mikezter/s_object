# -*- encoding: utf-8 -*-
require 'spec_helper'

module SObject
  describe Query do
    context 'initialization' do
      it 'with an object type' do
        lambda{ Query.new 'Account' }.should_not raise_error
      end

      it 'raises error without object type' do
        lambda{ Query.new }.should raise_error(ArgumentError)
      end
    end

    context 'fields' do
      before :each do
        @query = Query.new 'Account'
      end

      it 'is an array' do
        @query.fields.should be_kind_of(Array)
      end

      it 'always contains the id field' do
        @query.fields.should include('id')
      end
    end
  end
end

