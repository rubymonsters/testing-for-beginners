require "app"
require "rack/test"
require "rspec-html-matchers"
require "uri"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpecHtmlMatchers
end

RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    uri = URI.parse(response.headers['Location'])
    response.status == 302 && uri.path == path
  end
end
