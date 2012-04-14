module SObject
  class Request

    attr_reader :body, :method, :params, :data

    def self.run(url, options = {})
      new(url, options).run
    end

    def initialize(url, options = {})
      @url = url
      @body = options[:body] || ''
      @method = options[:method] || :get
      @params = options[:params] || {}
    end

    def run
      response = Typhoeus::Request.run @url, options
      @data = JSON.parse(response.body)
      raise_error unless response.success?
    end


  private

    def headers
      Authorization.headers
    end

    def raise_error
     object = data.first
     raise SObject.error_class_for(object['message'], object['errorCode'])
    end

    def options
     {
       :headers => headers,
       :body    => body,
       :params  => params
     }
    end

  end
end
