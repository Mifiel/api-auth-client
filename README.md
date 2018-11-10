# ApiAuth::Client

[![Gem Version][gem-version-image]][gem-version-url]
[![Build Status][travis-image]][travis-url]
[![Coverage Status][coveralls-image]][coveralls-url]
[![security][security-image]][security-url]

Use this gem to create simple API Client classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_auth-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_auth-client

## Usage

```ruby
class VolabitClient < ApiAuth::Client::Base
  connect url: 'https://www.volabit.com/api/v1'

  def tickers
    connection.get('/tickers')
  end

  # bang method, it will raise an error if it fails
  def tickers!
    connection.get!('/tickers')
  end

  # reqires auth
  def me
    connection.get('/users/me')
  end
end
```

### Access to the response

```ruby
client = VolabitClient.new
response = client.tickers
#<ApiAuth::Client::Response btc_mxn_buy="123255.81", btc_mxn_sell="127187.57", ltc_mxn_buy="999.96", ltc_mxn_sell="1033.07", bch_mxn_buy="10522.97", bch_mxn_sell="10873.06", xrp_mxn_buy="9.58", xrp_mxn_sell="9.9">
response[:btc_mxn_buy] == response['btc_mxn_buy'] == btc_mxn_buy.btc_mxn_buy

response[:unknown] == response['unknown'] == nil
response.unknown # raises NoMethodError
```

### Bang methods, RoR style

You can use bang `!` methods if you want the method to raise an error if the requests fails due to server error, bad requests or a bad connection.

```ruby
client = VolabitClient.new
begin
  response = client.tickers!
rescue ApiAuth::Client::ConnectionError =>
  e # => #<ApiAuth::Client::ConnectionError: Connection Error>
  e.response
  # { message: 'Failed to open TCP connection' }
  e.code # nil
rescue ApiAuth::Client::ApiEndpointError => e
  e # => #<ApiAuth::Client::ApiEndpointError: 500 Internal Server Error>
  e.response
  # <ApiAuth::Client::Response error="Bad JSON", body="500 Internal Server Error...">
  e.response.body
  e.code # 400
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_auth-client.

[gem-version-image]: https://badge.fury.io/rb/api_auth-client.svg
[gem-version-url]: https://badge.fury.io/rb/api_auth-client

[security-url]: https://hakiri.io/github/Mifiel/api-auth-client/master
[security-image]: https://hakiri.io/github/Mifiel/api-auth-client/master.svg

[travis-image]: https://travis-ci.org/Mifiel/api-auth-client.svg?branch=master
[travis-url]: https://travis-ci.org/Mifiel/api-auth-client

[coveralls-image]: https://coveralls.io/repos/github/Mifiel/api-auth-client/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/Mifiel/api-auth-client?branch=master
