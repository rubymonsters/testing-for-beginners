# Testing a Sinatra app

Let's go back to our Sinatra application that defined the `members` resource in our
[Webapps for Beginners](http://webapps-for-beginners.rubymonstas.org/exercises/sinatra_resource.html)
book.

We've written that app in what Sinatra calls the "classic style". That means
that we've simply defined the routes in the global namespace, not using any
class for them.

In order to make it easy for us to test the application using Rack::Test we need
to convert it to what Sinatra calls the "modular style". This simply means that
we require `sinatra/base` instead of `sinatra`, and then define a class that
inherits from `Sinatra::Base`:

```ruby
require "sinatra/base"

class Application < Sinatra::Base
  get "/members" do
    # ...
  end

  get "/members/new" do
    # ...
  end
end
```

We've converted the application, and included the code in our repository
[here](https://github.com/rubymonsters/testing-for-beginners/tree/master/code/sinatra).
In order to work with it, you can clone this repository from GitHub using
`git`, and `cd` into the directory `code/sinatra`.

You will notice that we've also extracted the class `Member` to a file
`member.rb`, and the `MemberValidator` to a file `member_validator.rb`. These
files are required at the top of the file `app.rb`, which is the main file, and
defines the class `App`.  Also, there's a `config.ru` file that allows us to
start the application separately.

This is nice, because it lets us focus better on our application code. However
it also means that we need to tell Ruby where to look for these files. I.e. we
have to setup the Ruby
[load path](http://webapps-for-beginners.rubymonstas.org/libraries/load_path.html)
properly.

When we use `ruby`, `rackup`, or `rspec` to load the file we can add the
current working directory to the Ruby load path by adding the option `-I .`.
The dot means "this current directory". The option `-I` tells Ruby to look for
files here when we use `require`.

In order to start the application you can run `rackup -I .`.

Ok, let's add some tests next.

For that we'll create a separate file `app_spec.rb`. RSpec wants us to name
files that contain tests with the suffix `_spec.rb`, and we want to keep
our code and tests separate this time.

We've also included a file `spec_helper.rb`. In RSpec this is a common place
to keep setup and configuration. Our spec helper doesn't do a lot, but it
requires our `app`, and includes the `Rack::Test::Methods` module to our
RSpec tests.

So in `app_spec.rb` we'll want to require the `spec_helper` first, and then
we're good to go, and can start writing tests:

```ruby
require "spec_helper"

describe App do
  it "works" do
    # ...
  end
end
```

We can run our tests like this:

```
$ rspec -I . app_spec.rb
.

Finished in 0.00052 seconds (files took 0.6769 seconds to load)
1 example, 0 failures
```

Of course we haven't implemented any actual test, yet.

So let's do that next.

## Taking notes first

Let's start adding tests in the order that the [exercise](http://webapps-for-beginners.rubymonstas.org/exercises/sinatra_resource.html)
specified.

In RSpec the method `it` can be used to write test stubs first, and mark them
as "to be done later", by simply not adding a block, just yet. This is nice
because it allows us to focus on what we want to test first, and then add the
test implementation later.

We'll just copy the requirements from the exercise, more or less:


```ruby
require "spec_helper"

describe App do
  let(:app) { App.new }

  context "GET to /members" do
    it "returns status 200 OK"
    it "displays a list of member names that link to /members/:name"
  end

  context "GET to /members/:name" do
    it "returns status 200 OK"
    it "displays the member's name"
  end

  context "GET to /members/new" do
    it "returns status 200 OK"
    it "displays a form that POSTs to /members"
    it "displays an input tag for the name"
    it "displays a submit tag"
  end

  context "POST to /members" do
    context "given a valid name" do
      it "adds the name to the members.txt file"
      it "returns status 302 Found"
      it "redirects to /members/:name"
    end

    context "given a duplicate name" do
      it "does not add the duplicate to the members.txt file"
      it "returns status 200 OK"
      it "displays a form that POSTs to /members"
      it "displays an input tag for the name, with the value set"
    end

    context "given an empty name" do
      it "does not add the name to the members.txt file"
      it "returns status 200 OK"
      it "displays a form that POSTs to /members"
      it "displays an input tag for the name, with the value set"
    end
  end
end
```

Does this make sense? We've basically formulated the specification from
[exercise](http://webapps-for-beginners.rubymonstas.org/exercises/sinatra_resource.html)
as RSpec test stubs.

You can see how we're using nested `context` blocks here for the first time.
This allows us to group our tests for the three cases of submitting a valid,
duplicate, or empty name.

If we run this, RSpec will tell us we have 19 "pending" tests to fill in:

```
rspec -I . app_spec.rb
************

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) App GET to /members returns status 200 OK
     # Not yet implemented
     # ./app_spec.rb:8

  [...[

  19) App POST to /members given an empty name displays an input tag for the name, with the value set
     # Not yet implemented
     # ./app_spec.rb:41


Finished in 0.0018 seconds (files took 0.59211 seconds to load)
19 examples, 0 failures, 19 pending
```

Cool.

Let's start filling them in.

## Adding test implementation

Since Sinatra uses Rack under the hood we can apply all the techniques we've
learned while writing tests for our Rack app.

We can create a new application instance with `App.new`, and make requests
using the `Rack::Test` helper methods `get`, `post`, and so on. These methods
will return a response object that we can inspect in our tests:

```ruby
require "spec_helper"

describe App do
  let(:app) { App.new }

  context "GET to /members" do
    let(:response) { get "/members" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays a list of member names that link to /members/:name" do
      expect(response.body).to include(
        '<a href="/members/Anja">Anja</a>',
        '<a href="/members/Maren">Maren</a>'
      )
    end
  end

  context "GET to /members/:name" do
    it "returns status 200 OK"
    it "displays the member's name"
  end
end
```

Does this work? Yes it does. These tests indeed pass:

```
$ rspec -I . --format doc app_spec.rb:6
Run options: include {:locations=>{"./app_spec.rb"=>[6]}}

App
  GET to /members
    returns status 200 OK
    displays a list of member names that link to /members/:name

Finished in 0.04964 seconds (files took 0.60312 seconds to load)
2 examples, 0 failures
```

Nice.

However, our test for the HTML tags is a little brittle. A test is brittle when
it breaks too easily. It's not robust enough.

In our case our specification says that there needs to be list of links that
show the name, and link to the right path. However, our test would fail if
we would, for example, add a CSS class to the links, so we can style them
more easily. Or if we'd add any other HTML attributes to it. Because we simply
compare the full HTML tag as a string.

Our app would then still function the same, and comply with the specification.
But our test would break. That's called a brittle test.

So what do we do?

## HaveTag matcher

One option would be to use a regular expression, like so:

```ruby
    it "displays a list of member names that link to /members/:name" do
      expect(response.body).to match %r(<a.* href="/members/Anja".*>Anja</a>)
      expect(response.body).to match %r(<a.* href="/members/Maren".*>Maren</a>)
    end
```

This is cool because we can use plain Ruby, but on the other hand regular
expressions are a little hard to read.

We could also implement a custom matcher for this. How about `have_tag`:

```ruby
RSpec::Matchers.define(:have_tag) do |name, content, attributes = {}|
  match do |html|
    # somehow figure out if `html` has the right tag.
  end
end
```

With that we could formulate our test like so:

```ruby
    it "displays a list of member names that link to /members/:name" do
      expect(response.body).to have_tag(:a, :href => "/members/Anja", :text => "Anja")
      expect(response.body).to have_tag(:a, :href => "/members/Maren", :text => "Maren")
    end
```

And leave the nitty gritty work of matching to our custom matcher.

Luckily there's a gem for that: [rspec-html-matchers](https://github.com/kucaahbe/rspec-html-matchers).
Let's try that. We need to install the gem and add it to RSpec it in our
`spec_helper.rb` file:

```ruby
require "rspec-html-matchers"

RSpec.configure do |config|
  # ...
  config.include RSpecHtmlMatchers
end
```

Ok, this works. Our test is now much less brittle, very cool.

Now let's have a look at the next route:

```ruby
  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays the member's name" do
      expect(response.body).to have_tag(:p, :text => "Name: Anja")
    end
  end
```

We can simply use all the same techniques for the `GET /members/:name` route.
Nothing new here.

These specs pass, too:

```
$ rspec -I . --format doc app_spec.rb:19
Run options: include {:locations=>{"./app_spec.rb"=>[19]}}

App
  GET to /members/:name
    returns status 200 OK
    displays the member's name

Finished in 0.08506 seconds (files took 0.80809 seconds to load)
2 examples, 0 failures
```

Cool. Ok, what about the form on `/members/new`?

```ruby
  context "GET to /members/new" do
    let(:response) { get "/members/new" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays a form that POSTs to /members" do
      expect(response.body).to have_tag(:form, :action => "/members", :method => "post")
    end

    it "displays an input tag for the name" do
      expect(response.body).to have_tag(:input, :type => "text", :name => "name")
    end

    it "displays a submit tag" do
      expect(response.body).to have_tag(:input, :type => "submit")
    end
  end
```

We seem to be getting the hang on this web application testing business.

These specs pass, too:

```
$ rspec -I . --format doc app_spec.rb:31
Run options: include {:locations=>{"./app_spec.rb"=>[31]}}

App
  GET to /members/new
    returns status 200 OK
    displays a form that POSTs to /members
    displays an input tag for the name
    displays a submit tag

Finished in 0.06903 seconds (files took 0.63294 seconds to load)
4 examples, 0 failures
```

Now the next route, `POST to /members` is going to be a little less trivial,
and we'll need to introduce a few new concepts here.

Let's see.

```ruby
  context "POST to /members" do
    let(:file) { File.read("members.txt") }

    context "given a valid name" do
      let(:response) { post "/members", :name => "Monsta" }

      it "adds the name to the members.txt file" do
        expect(file).to include("Monsta")
      end

      it "returns status 302 Found" do
        expect(response.status).to eq 302
      end
    end
```

These tests read as if they should pass, don't they? We think they do.

Except, they don't.

## Leaking state

When we run these tests something curious happens. At first the second test
(testing the status `302`) passes, and the first one does not. From then on,
when we re-run the tests, the first one passes, and the second one doesn't.

Why's that? This is a common problem in testing. Programmers say that "tests
leak state". By that they mean that there is something that persists state
(data), this state is modified when we run our tests, and our tests rely on it.
Now whenever we run our tests the state persisted in one test can influence the
next test. Thus, it leaks.

In our case this is the file `members.txt` of course. More precisely, our tests
rely on the assumption that the name `Monsta` is not in the persistent file
`members.text`.

But when we run our tests the first test that executes will add it, and save
the file. All other tests from then on run against a *different* persistent
state than the first one. That is bad.

We can fix that by resetting the contents of the file `members.txt` to the
same state before or after each test run. Let's do that:

```ruby
  context "POST to /members" do
    let(:response) { post "/members", :name => "Monsta" }
    let(:file)     { File.read("members.txt") }

    before { File.write("members.txt", "Anja\nMaren") }

    # ...
  end
```

I.e. for each of our tests, before RSpec runs it, it will execute the `before`
block first, and write the same content to the file.

This is an important concept in testing: You want your tests to always run
against the same state. If anything is persisted, e.g. in our file, in a
database, or anywhere else, we need to apply extra measures to make sure
this state is reset everytime we run a single test.

Cool. When we now run the tests we still get a failure. Our first test still
does not pass. However, we now get the same failure no matter how often we run
it.

So what's wrong with the first test?

## Side effects

If you think about it, we run the actual `POST` request in the `let(:response)`
statement. And so far, all of our tests have somehow used the `response`.
Therefore RSpec has executed the `POST` request, and we've seen the right
results.

However, this one test now does not use `response` at all. It looks at the file
contents instead. In programming, this is called a [side effect](http://programmers.stackexchange.com/questions/40297/what-is-a-side-effect).
We test something that is not returned from the method call that we need to
execute, and therefore our test happens to not make that method call at all.
You could also say that our test happens to reveal that we're testing a side
effect here. In this way tests can be diagnostic, and tell us things about
our code that we haven't noticed before.

In web applications side effects are expected: we do want to store (persist)
some data in our text file, or in the database. However, it is also good to
be aware of this.

We could fix our test like so:

```ruby
      it "adds the name to the members.txt file" do
        response
        expect(file).to include("Monsta")
      end
```

This will first make the `POST` request, and then inspect the file. In fact,
our test now passes:

```
$ rspec -I . --format doc app_spec.rb:57
Run options: include {:locations=>{"./app_spec.rb"=>[57]}}

App
  POST to /members
    given a valid name
      adds the name to the members.txt file
      returns status 302 Found

Finished in 0.04476 seconds (files took 0.64694 seconds to load)
2 examples, 0 failures
```

However, calling `response` in this place seems kind of weird, does it not? We
don't actually use the response object here. And the line does not really
convey that all we want to do is make the `POST` request here.

So what's an alternative?

## Let!

RSpec has another variation of the `let` method that makes this more visible:
`let!`.

`let!` is useful in exactly such situations: We need to evaluate the
`response`, because we need to tests a side effect. And we want to mark this as
an exceptional thing. The same line then also hints that we're making a `POST`
request.

That seems like a good compromise, let's use it:

```ruby
  context "POST to /members" do
    let(:file) { File.read("members.txt") }
    before     { File.write("members.txt", "Anja\nMaren") }

    context "given a valid name" do
      let!(:response) { post "/members", :name => "Monsta" }

      it "adds the name to the members.txt file" do
        expect(file).to include("Monsta")
      end
    end
  end
```

Ok, this looks great. Our tests pass, and we're using another nice RSpec
feature.

## Custom matchers

What's next? What about our redirect test? It would be nice if we could use a
matcher for that:

```ruby
      it "redirects to /members/:name" do
        expect(response).to redirect_to "/members/Monsta"
      end
```

In fact `rspec-rails`, a gem for testing Rails applications with RSpec, has such
a matcher. However, Rack::Test doesn't. So let's use that opportunity to write
our own custom matcher for this:

```ruby
RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    response.status == 302 && response.headers['Location'] == "http://example.org#{path}"
  end
end
```

Looks alright? We compare the actual response status to 302, and we compare the
response header `Location` to a URL that has our path.

What's with the `example.org` business though? As mentioned at some point in
the Webapps for Beginners book, a redirect header needs to be a full URL as per
the HTTP specification. So our Sinatra app turns the path into a full URL.
Since we haven't specified any other hostname in our app it just adds this
fantasy domain name.

This works, the given test would pass.

Can you spot a problem with it though?

Our matcher, again, is a brittle. What if we configure a proper hostname for
our app at some point? Our tests then would fail, even though the application
code would function as expected. Our tests would be too brittle, and fail when
they should pass.

Let's fix that, and parse the URL, so we can compare the path only:

```ruby
require 'uri'

RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    uri = URI.parse(response.headers['Location'])
    response.status == 302 && uri.path == path
  end
end
```

Now, that's much better.

There's one more aspect that is a little brittle, too: we test for a very
specific status code. According to the HTTP specification all status codes that
start with a `3` are considered [redirects](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_Redirection).

So let's fix that, too.

```ruby
RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    uri = URI.parse(response.headers['Location'])
    response.status / 100 == 3 && uri.path == path
  end
end
```

This is a trick, of course. The response status code is an `Integer`. So if we
divide it by `100` we'll get another `Integer`, in our case `3`, with any
decimals cut off.

We could also turn the number into a string and inspect the first character:

```ruby
RSpec::Matchers.define(:redirect_to) do |path|
  match do |response|
    uri = URI.parse(response.headers['Location'])
    response.status.to_s[0] == "3" && uri.path == path
  end
end
```

You decide which one you like better.

Ok, let's slap this matcher into our `spec_helper.rb` and see if it works:

```
$ rspec -I . --format doc app_spec.rb:65
Run options: include {:locations=>{"./app_spec.rb"=>[65]}}

App
  POST to /members
    given a valid name
      redirects to /members/:name

Finished in 0.039 seconds (files took 0.69768 seconds to load)
1 example, 0 failures
```

It does! Very nice.

## Shared examples

Let's fill in the tests for the next case, posting a duplicate name. We can
mostly steal from the tests we've already written for the `GET /members/new`
route.

Also, we can simply test that the file still has the expected contents:

```ruby
    context "given a duplicate name" do
      let!(:response) { post "/members", :name => "Maren" }

      it "does not add the name to the members.txt file" do
        expect(file).to eq "Anja\nMaren"
      end

      it "returns status 200 OK" do
        expect(response.status).to eq 200
      end

      it "displays a form that POSTs to /members" do
        expect(response.body).to have_tag(:form, :action => "/members", :method => "post")
      end

      it "displays an input tag for the name, with the value set" do
        expect(response.body).to have_tag(:input, :type => "text", :name => "name", :value => "Maren")
      end
    end
```

Now there's only one context missing: posting an empty string as a name.

This is interesting.

We could simply copy and paste the tests that we already have, and just change
the name in the before block (and the context description, of course).

However, this is also a great opportunity to look at one more, rather advanced
RSpec features: shared example groups.

RSpec allows us to define groups of tests (examples), and include them in
different contexts. And this is exactly what's really useful for us here.

Let's move our tests from the last context to a shared example group like so:

```ruby
    shared_examples_for "invalid member data" do
      it "does not add the name to the members.txt file" do
        expect(file).to eq "Anja\nMaren"
      end

      it "returns status 200 OK" do
        expect(response.status).to eq 200
      end

      it "displays a form that POSTs to /members" do
        expect(response.body).to have_tag(:form, :action => "/members", :method => "post")
      end

      it "displays an input tag for the name, with the value set" do
        expect(response.body).to have_tag(:input, :type => "text", :name => "name", :value => "Maren")
      end
    end
```

Now we can include these tests to our two contexts that deal with invalid
member data:

```ruby
    shared_examples_for "invalid member data" do
      # ...
    end

    context "given a duplicate name" do
      let!(:response) { post "/members", :name => "Maren" }
      include_examples "invalid member data"
    end

    context "given an empty name" do
      let!(:response) { post "/members", :name => "" }
      include_examples "invalid member data"
    end
```

That's really cool.

Our final tests now all pass:

```
$ rspec -I . --format doc app_spec.rb

App
  GET to /members
    returns status 200 OK
    displays a list of member names that link to /members/:name
  GET to /members/:name
    returns status 200 OK
    displays the member's name
  GET to /members/new
    returns status 200 OK
    displays a form that POSTs to /members
    displays an input tag for the name
    displays a submit tag
  POST to /members
    given a valid name
      adds the name to the members.txt file
      returns status 302 Found
      redirects to /members/:name
    given a duplicate name
      does not add the name to the members.txt file
      returns status 200 OK
      displays a form that POSTs to /members
      displays an input tag for the name, with the value set
    given an empty name
      does not add the name to the members.txt file
      returns status 200 OK
      displays a form that POSTs to /members
      displays an input tag for the name, with the value set

Finished in 0.14409 seconds (files took 0.62813 seconds to load)
19 examples, 0 failures
```

Why don't you go ahead and add some more specs for the remaining routes.

The groups

* `GET to /members/:name/edit` and `PUT to /members/:name` and
* `GET to /members/:name/delete` and `DELETE to /members/:name`

still need to be tested, and adding these tests makes an excellent exercise.

