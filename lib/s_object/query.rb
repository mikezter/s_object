module SObject
  class Query

    attr_reader :where, :type, :limit

    include Enumerable

    def initialize(object_type, options = {})
      raise ArgumentError.new unless object_type.is_a?(String)
      @type             = object_type

      @where            = Array(options[:where])
      @fields           = Array(options[:fields])
      @limit            = options[:limit]
      @url              = options[:url]
    end

    def fields
      (@fields + ['id']).collect(&:downcase).uniq
    end

    def next_query
      @next ||= Query.new(
        :url => next_records_url,
        :fields => fields,
        :type => type,
        :where => where,
        :limit => limit
      )
    end

    def each
      record_instances.each do |record|
        yield record
      end

      if more?
        next_query.each do |record|
          yield record
        end
      end
    end

    def done?
      data['done']
    end

    def more?
      not data['done']
    end

    def size
      data['records'].size
    end

    def total_size
      data['totalSize'].to_i
    end

    def data
      @data ||= JSON.parse(response.body)
    end

    def records
      data['records']
    end

    def record_instances
      @record_instances ||= records.collect do |record|
        record_class.new(record)
      end
    end

    def next_records_url
      Authorization.instance_url + data['nextRecordsUrl']
    end

    def record_class
      Factory.get(@type)
    end

    def url
      @url || Authorization.service_url + "/query"
    end

    def params
      return {} if @url
      { :q => query }
    end

    def query
      "SELECT #{fields.join(', ')} FROM #{type} #{wheres} #{limits}"
    end

    def limits
      "LIMIT #{limit}" if limit
    end

    def wheres
      @where ||= []
      return '' unless @where.any?
      where = 'WHERE '
      where += @where.join(' AND ')
      where
    end

    def response
      return @response if @response
      @response = Typhoeus::Request.get(
        url,
        :params => params,
        :headers => Authorization.headers
      )

      unless @response.success?
        error = JSON.parse(@response.body).first
        raise SObject.error_class_for(error['message'], error['errorCode'])
      end

      return @response
    end

  end
end

