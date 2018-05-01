require 'faraday'

module OBS

  class Binary < Hashie::Mash
    include Hashie::Extensions::Mash::SymbolizeKeys
  end

  class Collection < Hashie::Mash
    include Hashie::Extensions::Mash::SymbolizeKeys
    include Hashie::Extensions::Coercion
    coerce_key :binary, Array[Binary]
    coerce_key :matches, Integer

    def self.coerce(hash)
      c = Collection.new(hash)
      c[:binaries] = c.delete(:binary)
      c
    end
  end

  class Response < Hashie::Mash
    include Hashie::Extensions::Mash::SymbolizeKeys
    include Hashie::Extensions::Coercion
    coerce_key :collection, Collection
  end

  # Utility function to generate a xpath query from a search term and the following options:
  # @param [Hash] opts the options for the query.
  # @option opts [String] :baseproject OBS base project used to search packages for
  # @option opts [String] :project OBS specific project used to search packages into
  # @option opts [Boolean] :exclude_debug Exclude Debug packages from search
  # @option opts [String] :exclude_filter Exclude packages containing this term
  #
  def self.xpath_for(query, opts = {})
    baseproject = opts[:baseproject]
    project = opts[:project]
    exclude_debug = opts[:exclude_debug]
    exclude_filter = opts[:exclude_filter]

    words = query.split(" ").reject { |part| part.match(/^[0-9_\.-]+$/) }
    versrel = query.split(" ").select { |part| part.match(/^[0-9_\.-]+$/) }
    Rails.logger.debug "splitted words and versrel: #{words.inspect} #{versrel.inspect}"
    raise "Please provide a valid search term" if words.blank? && project.blank?

    xpath_items = []
    xpath_items << "@project = '#{project}' " unless project.blank?
    substring_words = words.reject { |word| word.match(/^".+"$/) }.map { |word| "'#{word.gsub(/['"()]/, '')}'" }.join(", ")
    unless substring_words.blank?
      xpath_items << "contains-ic(@name, " + substring_words + ")"
    end
    words.select { |word| word.match(/^".+"$/) }.map { |word| word.delete("\"") }.each do |word|
      xpath_items << "@name = '#{word.gsub(/['"()]/, '')}' "
    end
    xpath_items << "path/project='#{baseproject}'" unless baseproject.blank?
    xpath_items << "not(contains-ic(@project, '#{exclude_filter}'))" if !exclude_filter.blank? && project.blank?
    xpath_items << versrel.map { |part| "starts-with(@versrel,'#{part}')" }.join(" and ") unless versrel.blank?
    if exclude_debug
      xpath_items << "not(contains-ic(@name, '-debuginfo')) and not(contains-ic(@name, '-debugsource')) " \
                     "and not(contains-ic(@name, '-devel')) and not(contains-ic(@name, '-lang'))"
    end
    xpath = xpath_items.join(' and ')
    xpath
  end

  class << self
    attr_writer :client
    attr_reader :configuration
  end

  # Configure client
  #
  # @yield [configuration] configuration object to defining client paramters
  # @example
  #   OBS.configure do |config|
  #     config.api_key = "XYZ"
  #     config.adapter = :typhoeus
  #   end
  def self.configure(&block)
    @configuration ||= Configuration.new
    yield(@configuration) if block_given?

    self.client = Faraday.new(@configuration.api_host) do |conn|
      conn.basic_auth @configuration.api_username, @configuration.api_password
      conn.request :url_encoded
      conn.response :logger
      conn.response :mashify, :mash_class => Response
      conn.use FaradayMiddleware::ParseXml,  :content_type => /\bxml$/
      conn.adapter @configuration.adapter
    end
  end

  def self.client
    @client || configure
  end

  class Configuration
    attr_accessor :api_host, :api_username, :api_password, :adapter

    def initialize
      @adapter = Faraday.default_adapter
    end
  end

  # Searches for published binaries
  #
  # Utility function to generate a xpath query from a search term and the following options:
  # @param [String] query term to search for
  # @param [Hash] opts the options for the query.
  # @option opts [String] :baseproject OBS base project used to search packages for
  # @option opts [String] :project OBS specific project used to search packages into
  # @option opts [Boolean] :exclude_debug Exclude Debug packages from search
  # @option opts [String] :exclude_filter Exclude packages containing this term
  #
  def self.search_published_binary(query, opts={})
    OBS.client.get('/search/published/binary/id', match: xpath_for(query, opts)).body.collection
  end

  def self.search_project(query, opts={})
    OBS.client.get('/search/project/id', match: xpath_for(query, opts))
      .body
  end
end
