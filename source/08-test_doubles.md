# Test doubles

*Faking all the things*

Again, terminology about testing can be super confusing, and people have used
the terms used in this chapter in various, different ways. Even more confusing,
some test libraries use these terms in different ways, implementing different
kinds of behaviour.

For now we'll roll with the terms referenced by Martin Fowler in his famous
article [Mocks Aren't Stubs](http://martinfowler.com/articles/mocksArentStubs.html),
also referenced [here](http://stackoverflow.com/a/17810004/4130316).

This defines "test double" as an umbrella term for the following four terms:

* Mocks: Expectations about method calls, verifying them, and faking returning a value
* Stubs: Fake responses to method calls
* Fake: Objects with a working implementation that is useful for tests
* Dummy: Usually not very relevant in Ruby testing

Also, in Ruby, we might add this one to the list, instead of Dummy (which you
don't really see that often):

* Spies: Verifying that a stubbed method has been called before

Ok, that's a lot of stuff.

The two most commonly used techniqes are mocks and stubs. So let's focus on
these first:

<p class="hint">
Mocks and stubs are techniques that are used at the boundaries of the code
under test.
</p>

What?

In our `members` application the boundaries of our app are the Rack interface
on one side (which hooks into the server, and is called whenever a an actual
HTTP request comes in).

Most of the time, when we called our app in the `Rack::Test` based tests our
Ruby class (or: Sinatra app) just checked some conditions, rendered some
HTML, etc, and then returned a response object that we could test.

However, doing so it then also talks to something external: It reads and writes
to a text file that is stored on our hard drive. In other words, it uses an
external resource. Something that is not specific to our test or application
code (written in Ruby), but specific to the computer ("system") we're running
these tests on.

In most web applications this would be a database, not a text file. Sometimes
it also would mean that we'd make HTTP requests to talk to another application.
Or we might send emails, resize images or store PDF files, ... whatever our
application needs to produce in order to do its job, besides returning a
status code and some kind of HTML.

Mocks and stubs are useful techniques in tests in exactly these places: At the
boundary of our code and external "things".

## Stubs

Let's see how that looks like in praxis.

Imagine we'd want our code, when we test our `members` app to not actually
touch the `members.txt` file for whatever reason. Instead we'd like to fake
reading and writing to the file.

How can we do that?

RSpec has a built-in library called [rspec-mocks](https://www.relishapp.com/rspec/rspec-mocks/docs).
There are a bunch of [other libraries](https://www.ruby-toolbox.com/categories/mocking)
that provide similar functionality, most notably [Mocha](https://github.com/freerange/mocha)
which is really popular, too. We'll just use RSpec for now.

Consider our test code from before:

```ruby
describe App do
  let(:app) { App.new }
  before    { File.write('members.txt', "Anja\nMaren\n") }

  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }

    it "displays the member's name" do
      expect(response.body).to have_tag(:p, :text => "Name: Anja")
    end
  end
end
```

This code, under the hood, will read the file `members.txt`. Doing so it talks
to an "external system", i.e. our computer's operating system, in order to
access the file on the harddrive.

This method making this call might look like this:

```ruby
  def names
    File.read(FILENAME).split("\n")
  end
```

Now our objective is to make it so that the method call `File.read` is not
actually executed, but faked, and returns a value that we expect: some fake
content.

The RSpec documentation gives the following example about setting up stubs with
RSpec:

```ruby
allow(dbl).to receive(:foo).with(1).and_return(14)
```

Ok, so we "allow" an object (`dbl`) to "receive" a certain method call
(`:foo`), with a certain argument (`1`), and return a certain value (`14`).

That sounds like what we want. Let's try this:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec # use rspec-mocks
end

describe App do
  let(:app)      { App.new }

  before do
    allow(File).to receive(:read).with("members.txt").and_return("Anja\nMaren\n")
  end

  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }

    it "displays the member's name" do
      expect(response.body).to have_tag(:p, :text => "Name: Anja")
    end
  end
end
```

If you run this this test should pass. If you delete the file `members.txt` it
still passes.

What's going on here?

Under the hood, RSpec leverages Ruby's powerful capabilities in modifying,
replacing, and re-defining code at runtime.

Let's walk through it.

* In the before block, when RSpec has started executing our code, it replaces
  the method `read` with *another* method that, if it is passed the argument
  specified (in our case: the filename), will return the return value specified
  (the string that is our fake file content).

* When it then executes the test, calls our application, and our application
  calls the method `names`, it will call this fake ("stubbed") method
  `File.read?` instead of the original, real method that actually reads a file
  on the harddrive. The fake method will do nothing but return the value
  we specified: `"Anja\nMaren\n"`

* So to our application everything looks as if it was talking to the operating
  system, and looking at actual files on the harddrive, while actually it
  just calls fake methods that return the fake values we specified. Therefore
  the application functions just the same, and our tests passs, except it's not
  talking to the external system that is our computer at all at this point.

* After the test has run RSpec will then remove these fake methods, so that
  other tests (in other contexts that do not have this `before` block) could
  talk to the original, "real" method `File.read` again.

Wow. This is quite a bit of stuff to digest.

The core idea is that, when we `allow` an object to `receive` a method, RSpec
will create this fake method for the time the test runs, and it will remove
it again at the end.

Now, this is called "stubbing" a method. We replace it with a fake method,
so that we don't have to talk to an external system.

Btw if we would make a mistake, and stub the method call with the wrong arguments,
then RSpec would fail, and display an error like this:

```
RSpec::Mocks::MockExpectationError at members
File (class) received :read with unexpected arguments
  expected: ("members.text")
       got: ("members.txt")
 Please stub a default value first if message might be received with other args as well.
```

Because we've "allowed" the method to be called with certain arguments, but
not otherwise.

Some would argue that this is an implicit expectation or assertion, and that
stubs shouldn't actuall assert anything, but this is how RSpec stubs work.

## Mocks

Mocks on the other hand are pretty similar, but also very different.

Mocks are there to make assertions about methods being called during your
tests.

They work pretty much the same in that RSpec replaces the original method with
a fake method, and you can specify arguments as well as a return value.

However, RSpec will also record how often your method has been called during
your test. And at the end of the test it will not only remove this fake method
again, but also verify that the method has been called the expected number of
times (usually once) with the expected arguments.

Here's how that looks like in RSpec:

```ruby
describe App do
  let(:app) { App.new }

  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }

    it "displays the member's name" do
      expect(File).to receive(:read).with("members.txt").and_return("Anja\nMaren\n")
      get "/members"
    end
  end
end
```

This is called "mocking" a method: expecting and asserting that the method will
be called later.

Again, if we run this spec, but we make a mistake with the argument that we
expect to be passed (e.g. we have a typo `members.text`), then our tests will
fail:

```
$ rspec -I . app_spec.rb:15
Run options: include {:locations=>{"./app_spec.rb"=>[15]}}
F

Failures:

  1) App GET to /members/:name displays the member's name
     Failure/Error: expect(File).to receive(:read).with("members.text").and_return("Anja\nMaren\n")

       (File (class)).read("members.text")
           expected: 1 time with arguments: ("members.text")
           received: 0 times
     # ./app_spec.rb:16:in `block (3 levels) in <top (required)>'

Finished in 0.08187 seconds (files took 0.72415 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./app_spec.rb:15 # App GET to /members/:name displays the member's name
```

That makes sense, doesn't it? The method hasn't been called with these
arguments after all.

As you can see the workflow with mocked methods is a little different from
the workflow we've seen in our tests so far:

With mocked methods you have to set up your expectation *first*, then run
the actual code, and then RSpec will verify your expectation at the end.

Therefore we need to call `expect(File).to receive(:read)` first, and then
make the get request in our test above.

## Spies

RSpec therefore has another way to achieve the same, which is called a
"spying". [1]

Here's how method "spying" works in RSpec:

```ruby
describe App do
  let(:app) { App.new }

  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }
    let(:filename) { "members.txt" }
    let(:content)  { "Anja\nMaren\n" }

    before { allow(File).to receive(:read).with(filename).and_return(content) }

    it "displays the member's name" do
      get "/members"
      expect(File).to have_received(:read).with(filename)
    end
  end
end
```

As you can see that "fixes" the order: Our test first runs the get request,
and then verifies that the method `File.read` has been called with the expected
argument.

However, in order for that to work, we also have to stub the method in the
`before` block first. Otherwise RSpec would not have had the opportunity to
record calls to this method, and therefore raised an error like this:

```
Failure/Error: expect(File).to have_received(:read).with(filename)
 #<File (class)> expected to have received read, but that object is not a spy or method has not been stubbed.
```

To summarize:

* Stubbing and mocking methods replaces the original methods temporarily.
* Stubbing a method replaces it in order to fake it, and allow it to be called
  without executing the original, "real" method. This can be useful if we want
  our tests to not talk to external systems or code we do not want to test at
  the moment.
* Mocking a method asserts that the method actually is being called during our
  tests.
* Spying on a method (in RSpec) means verifying that a stubbed method has been
  called after the fact.

## Double objects

So far we've talked about replacing methods with fake methods that we'd either
allow or expect to be called during our tests.

Sometimes it is useful to have entire fake objects that can be passed around.

Consider this code from our [Ruby for Beginners]() book:

```ruby
class Person
  def initialize(name)
    @name = name
  end

  def name
    @name
  end

  def greet(other)
    "Hi " + other.name + "! My name is " + name + "."
  end
end

person = Person.new("Anja")
friend = Person.new("Carla")

puts person.greet(friend)
puts friend.greet(person)
```

Let's say we want to test that in RSpec, instead of just trying it out at the
end of the file.

We could turn this into tests like so:

```ruby
describe Person do
  let(:person) { Person.new("Anja") }
  let(:friend) { Person.new("Carla") }

  describe "greet" do
    it "returns a greeting" do
      expect(person.greet(friend)).to eq "Hi Carla! My name is Anja."
    end
  end
end
```

Now, imagine that, for whatever reason, it is really expensive or cumbersome to
create the `friend` instance.

In that case it would be useful to be able to quickly create a fake object (a
"double"), and allow the method `name` to be called on it: That's the only
method the method `person.greet` needs to call on the `other` object, right?

RSpec has a convient way of creating such fake objects (doubles):

```ruby
describe Person do
  let(:person) { Person.new("Anja") }
  let(:friend) { double(name: "Carla") }

  describe "greet" do
    it "returns a greeting" do
      expect(person.greet(friend)).to eq "Hi Carla! My name is Anja."
    end
  end
end
```

So, we do create a `Person` instance for the `person`, so we can actually call
the method `greet` on it. However, we do not create a second instance of the
same class. In the end, the method `greet` does not care what kind of object
is passed as `other`, as long as it responds to the method `name`, right? [2]

And yes, this test passes, too. Pretty cool.

## When to use doubles

Ok, this is all pretty interesting stuff. But how do you know when to use
stubs, mocks, spies, or fake objects?

As always, the answer clearly is, it depends. There are rarely any very clear
answers.

If your application talks to an external API (such as Twitter for signing in
users via OAuth, or GitHub for fetching some code that you'd like to inspect)
then that would be a very clear case. You definitely don't want your tests
to make any HTTP calls to an external API: not only is that super slow, but
it also would mean that you cannot work on your tests when your offline.

Generally, when talking to any external system is problematic, then that's
a good indication that you'd want to use a stub to fake that call.

Whether you need to also assert the call being made, i.e. when using a mock is
a good idea, is an entirely different question, and it is one that has been
debated for years.

Consider our tests from above:

```ruby
describe Person do
  let(:person) { Person.new("Anja") }
  let(:friend) { double(name: "Carla") }

  describe "greet" do
    it "returns a greeting" do
      expect(person.greet(friend)).to eq "Hi Carla! My name is Anja."
    end
  end
end
```

Our test does in no way verify that the method `name` actually has been
called on the fake `friend` object. What if we've accidentally left a hardcoded
value in our implementation, like so:

```ruby
class Person
  def greet(other)
    "Hi Carla! My name is " + name + "."
  end
end
```

Hmm, ok, that could happen. If we are concerned about this case then we
could verify the method call with a mock like so:

```ruby
    it "calls name on the other person" do
      expect(friend).to receive(:name).and_return("Carla")
      person.greet(friend)
    end
```

Or we could use a spy (this works fine because `friend` is a double, and
already has the method `name` stubbed):

```ruby
    it "calls name on the other person" do
      person.greet(friend)
      expect(friend).to have_receive(:name).and_return("Carla")
    end
```

Whether or not you want to add such tests to your test suite depends on many
factors.

In the end tests are there to make yourself (and your co-workers) feel
comfortable making changes to your code. When you run your tests you want to
feel safe enough to publish your code and not break anything (to your
production system, to your friends, to the open source community).

"Comfortable" is a very personal thing though. It depends on your personality,
experience, on your team, and everyone's views and gutfeelings.

This is true for testing in general, but it's also particularly true when
it comes to the question how much to test.

Remember tests are software, too. They also can have bugs, and cause making
changes hard, when you write too many, too detailed tests. On the other hand,
if you have too few tests, or test the wrong things, you might introduce a bug,
and cause yourself even more work fixing it. So it's a tradeoff, as always.

Over time, the more tests your write, you'll develop a good feeling, and your
own views. Maybe you'll work on different teams that have different conventions
for what to test, and how. It also helps to ask more experienced developers
about their views. Again, be prepared to get 10 different answers when you
ask 10 different people :)

One amazing talk on the differences between mocks and stubs, and when to use
what, has been given by Katrina Owen at Railsberry in 2013. You can watch it
[here](https://vimeo.com/68730418), and have a look at her slides
[here](https://speakerdeck.com/railsberry/zero-confidence-by-katrina-owen).
Check it out.


## Footnotes

[1] Spying on methods is used in various different ways, depending on the
library used. In the most popular Ruby libraries (such as
[RSpec](http://www.relishapp.com/rspec/rspec-mocks/v/3-5/docs/basics/spies),
[RR](http://technicalpickles.com/posts/ruby-stubbing-and-mocking-with-rr/),
[FlexMock](https://github.com/jimweirich/flexmock#spies)) "spying" refers to
the technique of verifying that a previously *stubbed* method actually has been
called, after the fact. In other contexts it means a technique that leaves the
original method in place, allows it to be called, but records the method call
so it can be verified later. Both techniques are similar, but also very
different in that the original method either needs to be stubbed (replaced)
first or can still be used.

[2] You've probably heard about the term "duck typing" at some point. This term
refers to the fact that in Ruby methods don't care what kind of objects are
being passed, as long as they behave in a certain way (respond to certain other
methods): As long as it walks like a duck, and quacks like a duck, ...
