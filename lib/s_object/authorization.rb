module SObject
  module Authorization
    extend self

    # login to salesforce using the provided credentials
    #
    # grant_type: password
    # access_token_url: https://test.salesforce.com/services/oauth2/token
    # client_id: abcdefghijklmnopqrst.vwxyz
    # client_secret: 1234567890
    # username: user@domain.com.testbox
    # password: passwordSECURITY_TOKEN
    #
    def login(config)
      @config = config.dup
      @access_token_url = @config.fetch 'access_token_url'
      credentials
    end

    def access_token
      credentials['access_token']
    end

    def instance_url
      credentials['instance_url']
    end

    def service_path
      "/services/data/#{SF_API_VERSION}"
    end

    def service_url
      instance_url + service_path
    end

    def reset
      @credentials = nil
    end

    def headers
      {
        'Authorization' => "OAuth #{access_token}",
        'Content-Type'  => 'application/json; charset=UTF-8',
        'Accept'        => 'application/json',
        "X-PrettyPrint" => "1"
      }
    end

    def credentials
      @credentials ||= request_credentials
    end

    private

    def request_credentials
      response = Typhoeus::Request.post(@access_token_url, params: @config)

      raise AuthenticationError.new(response.body) unless response.success?
      credentials = JSON.parse(response.body)

      # Salesforce doesn't seems to like requests straight after a token request
      sleep 1

      return credentials
    end

  end
end
