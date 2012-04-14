module SObject
  class Request

    attr_reader :body, :method, :params

    def initialize(url, options = {})
      @url = url
      @body = options[:body] || ''
      @method = options[:method] || :get
      @params = options[:params] || {}
    end

    def headers
      Authorization.headers
    end

    def run
      Typhoeus::Request.run @url, options
    end

   private

     def options
       {
         :headers => headers,
         :body    => body,
         :params  => params
       }
     end

  end
end
