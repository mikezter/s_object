SObject
=======

Creates a simple wrapper around Salesforce.com / Database.com SObjects.

Why should i use it instead of heroku/databasedotcom?
--------------------------------------------

It circumvents `QUERY_TOO_COMPLICATED` errors for SObjects with many fields.

Why should'nt i use it?
-----------------------

Some tests contained. Any help appreciated.

How do i use it?
----------------

Logging in:

    require 's_object'

    SObject::Authorization.login({
      grant_type       => 'password',
      access_token_url => 'https://test.salesforce.com/services/oauth2/token',
      client_id        => 'abcdefghijklmnopqrst.vwxyz',
      client_secret    => '1234567890',
      username         => 'user@domain.com.testbox',
      password         => 'passwordSECURITY_TOKEN'
    })

Retrieve Objects:

    SObject::Factory.get('Opportunity').first
    # => #<SObject::Opportunity:0x10d81d040 @fields={...}>

    SObject::Opportunity.find('006AABBCCDDEE')
    # => #<SObject::Opportunity:0x10d81d040 @fields={...}>

Issue arbitrary SOQL-Queries:

    SObject::Query.new(:type => 'Account', :fields => %w(Id firstName lastName), :where => 'ownerId=ABCDEFG')
    # => #<SObject::Account:0x10d81d040 @fields={...}>

Thank you