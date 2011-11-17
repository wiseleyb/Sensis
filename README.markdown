# Sensis Search
This is a pretty basic api wrapper for Sensis searching.

For more information on Sensis see their developer site: http://developers.sensis.com.au/

## Install

gem install sensis

## Usage
You can get a free api key at http://developers.sensis.com.au/

Note - all methods (search, get_listing_by_id and report) all take an additional key:  :env => "test" or "prod".  This decides if the test endpoint or the production endpoint will be used.  It defaults to "test".  You can specify this in the config if you don't want to pass it.

All results can be accessed by their hash values or by method names... example:

    res["code"] == res.code
    res["results"].size == res.results.size

## Config
If you don't want to pass your api_key or endpoint env every time you can put it config/sensis.yml

    development:
      api_key: abcdefg
      env: test

    test:
      api_key: abcdefg
      env: test

    production:
      api_key: abcdefg
      env: prod

### Search  

    res = Sensis.search(:key => "your api key", :query => "poker")
    
Or - if you are using the config...

    res = Sensis.search(:query => "poker")
  
Sensis.search takes a hash of options defined here: http://developers.sensis.com.au/docs/endpoint_reference/Search

Sample Search result set:  see http://developers.sensis.com.au/docs/endpoint_reference for more information

    {
      "results": [
          {
              "id": "999",
              "name": "Bob's Hairdresser",
              "categories": [
                  {
                      "name": "Hairdressers"
                  }
              ],
              "primaryAddress" {
                  "addressLine": "123 Fitzroy Street",
                  ...
              }
              ...
          }
          ...
      ],
      ...
      "count": 20,
      "totalResults": 19791,
      "executedQuery": "hairdresser",
      "originalQuery": "hairdresser",
      "date": "2011-02-28T12:01:02.345+1000",
      "time": 10,
      "code": 200,
      "message": "OK"
    }

So - you could do something like:

    res.results.first.name == res["results"][0]["name"]

#### Search paging

    res = Sensis.search(:key => "your api key", :query => "poker")
    pages = res.totalResults.to_i / 20
    pages.times do |page|
      res = Sensis.search(:key => "your api key", :query => "poker", :page => (page +1).to_s)
    end

More on paging in the docs http://developers.sensis.com.au/docs/using_endpoints/Pagination

### Get Listing By ID

    res = Sensis.get_listing_by_id(:key => "your api key", :query => "999")

Or - if you are using the config...

    res = Sensis.get_listing_by_id(:query => "999")
  
Sample result set: see for more information

    {
        "results": [
            {
                "businessId": "999",
                "businessName": "Hairdresser",
                "categories": [
                    {
                        "name": "Hairdressers"
                    }
                ],
                "primaryAddress": {
                    "addressLine": "123 Fitzroy Street",
                },
                ...
            }
        ],
        "count": 1,
        "totalResults": 1,
        "executedQuery": "999",
        "originalQuery": "999",
        "date": "2011-02-28T12:01:02.345+1000",
        "time": 10,
        "code": 200,
        "message": "OK"
    }

### Report
  
    res = Sensis.report(:key => "your api key", :userIp => "192.1.2.3", :userAgent => "Mozilla Firefox", 
      :userSessionId => "123467890", 
      :id => "VyY2UiOiJZRUxMT1ciLCJwcm9kdWN0SWQiOiIxMjM0IiwicHJvZHVjdFZlcnNpb24iOiI1Njc4In0")

Or - if you are using the config...

    res = Sensis.report(:userIp => "192.1.2.3", :userAgent => "Mozilla Firefox", 
      :userSessionId => "123467890", 
      :id => "VyY2UiOiJZRUxMT1ciLCJwcm9kdWN0SWQiOiIxMjM0IiwicHJvZHVjdFZlcnNpb24iOiI1Njc4In0")
    
You can also include multiple ID's by passing an array

    res = Sensis.report(:key => "your api key", :userIp => "192.1.2.3", :userAgent => "Mozilla Firefox", 
      :userSessionId => "123467890", 
      :id => ["1","2","3","4"])


Sample report result set:  see http://developers.sensis.com.au/docs/endpoint_reference/Report for more information

    {
        "results": [
            {
                "id": "999",
                "name": "Bob's Hairdresser",
                "categories": [
                    {
                        "name": "Hairdressers"
                    }
                ],
                "reportingId":"VyY2UiOiJZRUxMT1ciLCJwcm9kdWN0SWQiOiIx ⤶
    MjM0IiwicHJvZHVjdFZlcnNpb24iOiI1Njc4In0",
                ...
            }, 
            {
                "id": "1000",
                "name": "Jill's Hairdresser",
                "categories": [
                    {
                        "name": "Hairdressers"
                    }
                ],
                "reportingId":"eyJib29rSWQiOiJTMDBXIiwibGlzdGluZ05hbW ⤶
    UiOiJzdWJzY3JpYmVyTmFtZSIsInNvdXJjZSI6",
                ...
            }
            ...
        ],
        ...
        "count": 20,
        "totalResults": 19791,
        "executedQuery": "hairdresser",
        "originalQuery": "hairdresser",
        "date": "2011-02-28T12:01:02.345+1000",
        "time": 10,
        "code": 200,
        "message": "OK"
    }

## TODO
 * add more tests
 * add better examples for Get Listing By ID and Report.  Haven't really used these yet.

## Testing
 1. clone the code: git clone git://github.com/wiseleyb/Sensis.git
 2. gem install bundler
 3. bundle install
 4. copy spec/dummy/config/sensis.yml.example to sensis.yml
 5. fill in your api_key in sensis.yml
 
    bundle exec rspec spec
 
## Console
If you're working on the gem you can muck around in console by

 1. copy spec/dummy/config/sensis.yml.example to sensis.yml
 2. fill in your api_key in sensis.yml
 
    cd spec/dummy
    bundle execute rails c

### Credits

Thank you to jdunwoody for some sample sensis code https://github.com/jdunwoody/SensisSearchApp/blob/master/lib/search_command.rb

Thank you to mikedemers for some cool json -> class method code (class ResponseData) https://github.com/mikedemers/rbing/blob/master/lib/rbing.rb

# Change log
0.0.1 - initial release
0.0.2 - adding sensis.yml support for storing api_keys and env setting
