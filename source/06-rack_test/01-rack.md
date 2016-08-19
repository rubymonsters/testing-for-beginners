# Testing a Rack app

Let's grab our very Rack application from the book
[Webapps for Beginners](http://webapps-for-beginners.rubymonstas.org/rack/hello_world.html).

It looked like this:

```ruby
class Application
  def call(env)
    handle_request(env["REQUEST_METHOD"], env["PATH_INFO"])
  end

  private

    def handle_request(method, path)
      if method == "GET"
        get(path)
      else
        method_not_allowed(method)
      end
    end

    def get(path)
      [200, { "Content-Type" => "text/html" }, ["You have requested the path #{path}, using GET"]]
    end

    def method_not_allowed(method)
      [405, {}, ["Method not allowed: #{method}"]]
    end
end
```

How do we test such an app?

We could do this manually in RSpec like so:

```ruby
describe Application do
  context "get to /ruby/monstas" do
    it "returns the body" do
      env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/ruby/monstas" }
      response = app.call(env)
      body = response[2][0]
      expect(body).to eq "You have requested the path /ruby/monstas, using GET"
    end
  end
end
```

Or we could make some of this a little more reusable, like so:

```ruby
describe Application do
  context "get to /ruby/monstas" do
    let(:app)      { Application.new }
    let(:env)      { { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/ruby/monstas" } }
    let(:response) { app.call(env) }
    let(:body)     { response[2][0] }

    it "returns the body" do
      expect(body).to eq "You have requested the path /ruby/monstas, using GET"
    end
  end
end
```

And add a test for the status code:

```ruby
describe Application do
  context "get to /ruby/monstas" do
    let(:app)      { Application.new }
    let(:env)      { { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/ruby/monstas" } }
    let(:response) { app.call(env) }
    let(:status)   { response[0] }
    let(:body)     { response[2][0] }

    it "returns the status 200" do
      expect(status).to eq 200
    end

    it "returns the body" do
      expect(body).to eq "You have requested the path /ruby/monstas, using GET"
    end
  end
end
```

This passes:


```
$ rspec rack_spec.rb
..

Finished in 0.00086 seconds (files took 0.1486 seconds to load)
2 examples, 0 failures
```

Our Rack application is just a Ruby class which, when started (e.g. with
`rackup`), will be hooked up to the web server, and called whenever an HTTP
request comes in (e.g. from the browser).

But we can also just instantiate it ourselves, and call the method `call` with
a hash that complies to the Rack `env` conventions. E.g. in our case we'd want
to set the `REQUEST_METHOD` and `PATH_INFO` keys.

While this works well it's also a little bit of a hassle. And that's where
Rack::Test can help.

Here's how we can use Rack::Test to make our tests a little less verbose:


```ruby
require "rack/test"

describe Application do
  include Rack::Test::Methods

  context "get to /ruby/monstas" do
    let(:app) { Application.new }

    it "returns the status 200" do
      get "/ruby/monstas"
      expect(last_response.status).to eq 200
    end

    it "returns the body" do
      get "/ruby/monstas"
      expect(last_response.body).to eq "You have requested the path /ruby/monstas, using GET"
    end
  end
end
```

Rack::Test's helper methods expect that there's a method `app` defined, so they
can call it.  We can implement that using RSpec's handy `let` feature.

Now we first call the Rack::Test method `get` with our path. This method
creates the `env` hash for us, and calls `call` on the application. So we don't
have to compose the nasty hash ourselves.

After this, the method `last_response` will return the response that our
request has returned, and we can test it.

But the method `get` also returns the same response. So we could make this
a little more concise, and remove the duplicate call `get "/ruby/monstas"` like
this:


```ruby
require "rack/test"

describe Application do
  include Rack::Test::Methods

  context "get to /ruby/monstas" do
    let(:app)      { Application.new }
    let(:response) { get "/ruby/monstas" }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include "/ruby/monstas, using GET" }
  end
end
```

We can also remove the `include` line from our actual tests, and move it to
the RSpec configuration. This configuration normally would sit in a separate
file called `spec_helper.rb`, but for now we'll just move it above our test
code:

```ruby
require "rack/test"

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

describe Application do
  context "get to /ruby/monstas" do
    let(:app)      { Application.new }
    let(:response) { get "/ruby/monstas" }

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include "/ruby/monstas, using GET" }
  end
end
```

Nice.

Let's add another test for the case when an unsupported HTTP method is used:

```ruby
describe Application do
  let(:app) { Application.new }

  context "get to /ruby/monstas" do
    let(:response) { get "/ruby/monstas" }
    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include "/ruby/monstas, using GET" }
  end

  context "post to /" do
    let(:response) { post "/" }
    it { expect(response.status).to eq 405 }
    it { expect(response.body).to eq "Method not allowed: POST" }
  end
end
```

As you see we've moved the `let(:app)` statement one level up so it can be
shared among both contexts. the `let(:response)` statement on the other
hand is different for both contexts, so we kept them there.

Again, this passes:

```
$ rspec rack_spec.rb
....

Finished in 0.01175 seconds (files took 0.21704 seconds to load)
4 examples, 0 failures
```

Very cool. We've used RSpec and Rack::Test to write a few tests for the
functionality in our first Rack application.

Let's head over to the next chapter and do the same for our Sinatra resource
from the Webapps for Beginners book. We'll see a few more Rack::Test helper
methods there.
