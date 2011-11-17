require 'rubygems'
require 'json'
require 'net/http'

module Sensis

  def Sensis.config
    if @config.nil?
      config_file = "#{::Rails.root}/config/sensis.yml"
      if File.exists?(config_file)
        @config = YAML.load_file(config_file)
        @api_key = @config[::Rails.env]["api_key"]
        @env    = @config[::Rails.env]["env"]
      end
    end
    return @config
  end
  
  def Sensis.api_key
    @api_key ||= Sensis.config[::Rails.env]["api_key"] unless Sensis.config.nil?
  end
  
  def Sensis.env
    @env ||= Sensis.config[::Rails.env]["env"] unless Sensis.config.nil?
  end
  
  # Search - http://developers.sensis.com.au/docs/endpoint_reference/Search
  # options (from http://developers.sensis.com.au/docs/endpoint_reference/Search)
  # key                   string  API key (required)  See Authenticating for details.
  # query                 string  What to search for (required unless location is given)  See Search Query Tips for details.
  # location              string  Location to search in (required unless query is given)  See Location Tips for details.
  # page                  number  Page number to return.  See Pagination for details.
  # rows                  number  Number of listings to return per page.  See Pagination for details.
  # sortBy                string  Listing sort order. See Sorting for details.
  # sensitiveCategories   boolean Filtering potentially unsafe content. See Filtering Unsafe Content for details.
  # categoryId            string  Filter listings returned by category id See Category Filtering for details.
  # postcode              string  Filter listings returned by postcode  See Postcode Filtering for details.
  # radius                number  Filter listings returned to those within the radius distance of the location. See Radius Filtering for details.
  # suburb                string  Filter listings returned to those within the given suburb. Repeat the parameter to include multiple suburbs in the filter.  See Suburb Filtering for details.
  # state                 string  Filter listings returned to those within the given state. Repeat the parameter to include multiple states in the filter.  See State Filtering for details.
  # boundingBox           string  Filter listings returned to those within a bounding box.  See Bounding Box Filtering for details.
  # content               string  Filter listings returned to only those with certain types of content. See Filtering by Content Type for details.
  # productKeyword        string  Filter listings returned to only those containing certain product keywords. See Filtering by Product Keyword for details.
  # mode            string              Default is "test" - values "test","prod" - decides which endpoint is used - test or production
  # Example - Sensis.serch(:key => "key you got from developers.sensis.com.au", :query => "poker")
  def Sensis.search(options = {})
    options[:key] ||= Sensis.api_key
    errors = []
    errors << ":key (api key) is required" if options[:key].blank?
    errors << ":query or :location is required" if options[:query].blank? && options[:location].blank?
    raise errors.join("; ") unless errors.empty?
    Sensis.execute("search", options)
  end
  
  # Get Listing By ID - http://developers.sensis.com.au/docs/endpoint_reference/Get_by_Listing_ID
  # options
  # key	    string	API key (required)	See Authenticating for details.
  # query	  string	Unique ID of the listing to return (required)	This is the id field of the listing. See Listing Schema for details.
  # mode            string              Default is "test" - values "test","prod" - decides which endpoint is used - test or production
  def Sensis.get_listing_by_id(options = {})
    options[:key] ||= Sensis.api_key
    errors = []
    errors << ":key (api key) is required" if options[:key].blank?
    errors << ":query is required" if options[:query].blank? 
    raise errors.join("; ") unless errors.empty?
    Sensis.execute("getByListingId", options)
  end
  
  # Report - http://developers.sensis.com.au/docs/endpoint_reference/Report
  # key             string              API key (required)  See Authenticating for details.
  # userIp          string              IP address of user accessing your application (required)  See Reporting Usage Events for details.
  # id              string or an array  reportingId of listing associated with event (required) The reportingId field provided in each listing returned in a search response. Multiple id parameters can be added where the same event applies to each listing, except where the content parameter is specified. See Reporting Usage Events for details.
  # userAgent       string              User agent of user accessing your application For example, from the user-agent HTTP header. See Reporting Usage Events for details.
  # userSessionId   string              Session id of user accessing your application See Note below.
  # content         string              Specific content to which the event applies (required)  Only required for certain events. See Reporting Usage Events for details.
  # mode            string              Default is "test" - values "test","prod" - decides which endpoint is used - test or production
  def Sensis.report(options = {})
    options[:key] ||= Sensis.api_key
    errors = []
    errors << ":key (api key) is required" if options[:key].blank?
    errors << ":userIp is required" if options[:userIp].blank?
    errors << ":id is required" if options[:id].blank?
    raise errors.join("; ") unless errors.empty?
    Sensis.execute("report", options)
  end
  
  def Sensis.execute(endpoint_type, options)
    # location of the search endpoint
    endpoint = Sensis.endpoint(endpoint_type, options)

    # construct a URL with the query string, escaping any special characters.
    url = "#{endpoint}?"
    options.keys.each do |k|
      if options[k].is_a?(Array)
        options[k].each do |v|
          url = "#{url}&#{k}=#{URI.encode(v)}"
        end
      else
        url = "#{url}&#{k}=#{URI.encode(options[k].to_s)}"
      end
    end

    # call the endpoint, returning the HTTP response
    response = Net::HTTP.get_response(URI.parse(url))

    # raise an exception if not HTTP 200 (OK)
    response.error! unless response.instance_of? Net::HTTPOK

    # convert the response message in to a Hash object
    result = JSON.parse(response.body)

    res = ResponseData.new(result) if result

    # ensure successful status code
    case result["code"]
      when 200 # success
        return res
      when 206 # spell-checker was run
        puts "Note: #{result["message"]}"
        return res
      else
        raise "API returned error: #{res.message}, code: #{result.code}"
    end
  end
  
  def Sensis.endpoint(endpoint_type, options)
    env ||= options.delete(:env)
    env ||=  Sensis.env
    env ||= "test"
    endpoint = "http://api.sensis.com.au/ob-20110511/#{env}/#{endpoint_type}"
    endpoint = "#{endpoint}/#{options[:eventName]}" if endpoint_type == "report"
    return endpoint
  end
  
  # from https://github.com/mikedemers/rbing/blob/master/lib/rbing.rb
  class ResponseData < Hash
  private
    def initialize(data={})
      data.each_pair {|k,v| self[k.to_s] = deep_parse(v) }
    end
    def deep_parse(data)
      case data
      when Hash
        self.class.new(data)
      when Array
        data.map {|v| deep_parse(v) }
      else
        data
      end
    end
    def method_missing(*args)
      name = args[0].to_s
      return self[name] if has_key? name
      camelname = name.split('_').map {|w| "#{w[0,1].upcase}#{w[1..-1]}" }.join("")
      if has_key? camelname
        self[camelname]
      else
        super *args
      end
    end
  end
  
end


# def example()
#   # perform a search for 'hairdresser'
#   results = perform_search("hairdresser", "st kilda, vic")
# 
#   puts "Total results found: #{results["totalResults"]}"
# 
#   # the results member is an array containing each listings as a nested Hash object
#   results["results"].each do |r|
#     puts "#{r["name"]} (#{r["primaryAddress"]["addressLine"]})"
#   end
# end
# 
# # ZemantaFu
# require 'net/http'
# require 'rubygems'
# require 'xmlsimple'
# 
# class ZemantaFu
# 
#   # refer to http://developer.zemanta.com/docs/suggest/ for valid options
#   def self.search(text, options = {})
#     # tags - keywords
#     # in-text links
#     # categories
#     
#     options[:method] ||= "zemanta.suggest"
#     options[:format] ||= "xml"
#     options[:return_categories] ||= "dmoz"
#     options[:api_key] ||= "o26uvljcvr6q9l0zf155difg"
#     # options[:return_images] ||= 0
#     options[:markup_limit] ||= 1000
#     options[:articles_limit] ||= 1000
#     
#     options[:text] = text
#     
#     [:api_key].each do |k|
#       raise "Missing required key :#{k} in options." unless options.has_key?(k)
#     end
#     
#     gateway = 'http://api.zemanta.com/services/rest/0.0/'
#     res = Net::HTTP.post_form(URI.parse(gateway), options.stringify_keys)
#     data = XmlSimple.xml_in(res.body)
#     res = ResponseData.new(data) 
#     
#     # clean up top level arrays so that we can do
#     #   search("poker").articles
#     # instead of 
#     #   search("poker"").articles[0].article 
#     res.keys.each do |k|
#       ks = k.singularize
#       if res[k][0] && res[k][0].is_a?(Hash) && res[k][0].keys.include?(ks)
#         res[k] = res[k][0][ks]
#       else
#         res[k] = res[k][0]
#       end
#     end
#     # ensure there's something there for everthing
#     ["articles", "images", "keywords", "categories"].each do |k|
#       res[k] ||= []
#     end
#     # fix markup section
#     if res["markup"]["links"] == [{}]
#       res["markup"]["links"] = []
#     else
#       res["markup"]["links"] = res.markup.links.first.link
#       res["markup"]["links"].each_with_index do |link, index|
#         res["markup"]["links"][index]["targets"] = res["markup"]["links"][index]["target"]
#       end
#     end
#     return res
#   end
# 
#   # ResponseData modified from the rbing project https://raw.github.com/mikedemers/rbing/master/lib/rbing.rb
#   class ResponseData < Hash
#     
#     def save(filename)
#       File.open(filename, 'w') do |out|
#         YAML.dump(self, out)
#       end
#     end
#     
#     private
#     
#     def initialize(data={})
#       data.each_pair {|k,v| self[k.to_s] = deep_parse(v) }
#     end
#     
#     def deep_parse(data)
#       case data
#       when Hash
#         self.class.new(data)
#       when Array
#         data.map {|v| deep_parse(v) }
#       else
#         data
#       end
#     end
#     
#     def method_missing(*args)
#       name = args[0].to_s
#       res = nil
#       if has_key? name
#         res = self[name] 
#       else
#         camelname = name.split('_').map {|w| "#{w[0,1].upcase}#{w[1..-1]}" }.join("")
#         if has_key? camelname
#           res = self[camelname]
#         else
#           super *args
#         end
#       end
#       if res.nil?
#         super *args
#       else
#         # Zemanta returns all final values as arrays... get rid of this so, for example
#         # res.status = "ok" and not ["ok"]
#         if res.is_a?(Array) && res.size == 1 && res.first.is_a?(String) == true
#           return res.first
#         else
#           return res
#         end
#       end
#     end
#     
#   end
# 
#   # 
#   class Parameters
#     OPTION_KEYS = [:parameter, :description, :required, :possible_values, :default_value]
#     OPTIONS = [
#       [:method, "Method on the server", true, "zemanta.suggest", "zemanta.suggest"],
#       [:api_key, "Your API key", true, "string", nil],
#       [:text, "Input text (clear text or HTML)", true, "string", nil],
#       [:format, "requested output format", true, ["xml", "json", "wnjson", "rdfxml"], "xml"],
#       [:return_rdf_links, "return URIs of Linking Open Data entities", false, [0, 1], nil],
#       [:return_categories, "categorize into specified categorization scheme", false, ["dmoz","partner ID"], "dmoz"],
#       [:return_images, "return related images (default is yes) This can cause dramatic performance improvements", false, [0, 1], "yes"],
#       [:return_keywords, "return keywords (default is yes) This can affect performance slightly positively", false,  [0, 1], "yes"],
#       [:emphasis, %(terms to "emphasise", even when not present in text. All related articles are then required to have this term.), false, "string", nil],
#       [:text_title, "[NEW since August 2010]  Title of the text you are sending. Helps the text understanding algorithm.",  false, "string", nil],
#       [:personal_scope, "return only personalized related articles and images", false, [0, 1], nil],
#       [:markup_limit, "Number of in-text links to return (default: depending on the number of input words, 1 per each 10 words, and it maxes out at 10)", false, "number", 10],
#       [:images_limit, "Number of images to return (default:24)", false, "number", 24],
#       [:articles_limit, "Number of articles to return (default:10)", false, "number", 10],
#       [:articles_max_age_days,  "Maximum age of returned articles (default: no limit)", false, "number", nil],
#       [:articles_highlight, "[NEW since August 2010] Should a highlighted search snippet for each article be returned, where available (default: no)", false, "number", 0],
#       [:image_max_w, "Maximum image width (default: 300)", false, "number", 300],
#       [:image_max_h, "Maximum image height (default: 300)", false, "number", 300],
#       [:sourcefeed_ids, "ID for personalized related articles", false, nil],
#       [:flickr_user_id, "flickr ID of the user", false, nil],
#       [:pixie, "the chosen Zemanta signature icon", false, nil]
#     ]
#   end
#   
# end