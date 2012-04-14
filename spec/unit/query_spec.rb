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

  end
end

