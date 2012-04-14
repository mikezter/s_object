require 'spec_helper'

module SObject
  describe Factory do
    it 'initializes with a type given as string' do
      lambda{ Factory.new('Opportunity') }.should_not raise_error
    end

    context 'get' do

      it 'defines a new class in module SObject' do
        SObject.const_defined?('Opportunity').should be false
        Factory.new('Opportunity').get
        SObject.const_defined?('Opportunity').should be true
      end

      it 'provides a class method shortcut' do
        factory = mock
        factory.should_receive(:get).and_return double
        Factory.should_receive(:new, :with => 'Opportunity').and_return factory
        Factory.get('Opportunity')
      end

      it 'removes __c suffix from sobject type names before creating classes' do
        custom_sobject_type = 'Mission__c'
        SObject.const_defined?('Mission').should be false
        SObject.const_defined?('Mission__c').should be false
        Factory.new(custom_sobject_type).get
        SObject.const_defined?('Mission').should be true
        SObject.const_defined?('Mission__c').should be false
      end

    end

  end
end

