# Basic Usage

RSpec tests can be written in several flavors, or styles. Let's have a look at
the most basic one first.

RSpec wants us to define tests in a file that ends with `_spec.rb`, so we store
both our class and our test in the file `user_spec.rb`. Normally, in modern
codebases, you'd store your code in one file, and your tests in another file:

```ruby
require "date"

def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end

class User
  def initialize(name, birthday)
    @name = name
    @birthday = birthday
  end

  def name
    @name
  end

  def born_in_leap_year?
    leap_year?(Date.parse(@birthday).year)
  end
end

describe User do
  it "is born in a leap year when born in 2000" do
    user = User.new("Francisca", "2000-01-01")
    actual = user.born_in_leap_year?
    expected = true
    expect(actual).to eq expected
  end
end
```

Does that read ok?

We're going to work with this test more later, so let's shorten that a bit and
use less space, by removing the `actual` and `expected` variables:


```ruby
describe User do
  it "is born in a leap year when born in 2000" do
    user = User.new("Francisca", "2000-01-01")
    expect(user.born_in_leap_year?).to eq true
  end
end
```

Ok. That's the same, but uses 2 lines instead of 4.

Remember how Sinatra is a [DSL](http://webapps-for-beginners.rubymonstas.org/sinatra/dsl.html),
a language, for "talking" about (writing code that deals with) the problem
domain of HTTP, i.e. writing web applications?

RSpec is a DSL for the problem domain of writing tests (or "specifications").

While Sinatra defines methods such as `get`, `post`, `status`, `redirect`, and
so on, RSpec defines methods like `describe`, `it`, and `expect`.

Using these methods you can describe your expectations about your code, and
execute them. In RSpec's thinking, that's what tests are all about: expressing
your expectations about the behaviour of your code. We *describe* the class
`User`, and specify our expectations.

Instead of `it` you can also use `example`. That's exactly the same:

```ruby
describe User do
  example "is born in a leap year when born in 2000" do
    # ...
  end
end
```

Also, suppose we have many tests that deal with the case that a user was
born in 2000, maybe like this:

```ruby
describe User do
  it "is born in a leap year when born in 2000" do
    # ...
  end

  it "is at voting age when born in 2000" do
    # ...
  end
end
```

RSpec allows us to group such tests (examples) like so:

```ruby
describe User do
  describe "when born in 2000" do
    it "is born in a leap year" do
      # ...
    end

    example "is at voting age" do
      # ...
    end
  end
end
```

And again, there's an alias for nested `describe` blocks: You can use `context`
there, too:

```ruby
describe User do
  context "when born in 2000" do
    it "is born in a leap year" do
      # ...
    end

    example "is at voting age" do
      # ...
    end
  end
end
```

Nice, isn't it? Our spec says: "A user, in the context of being born in 2000,
is born in a leap year", and then "[in the same context] is at voting age".

In short the methods `describe` and `context` are used to set up a logical
structure for your tests. There needs to be at least one toplevel `describe`
block. This is the equivalent to defining a class that inherits from
`Minitest::Test`.

The method `it` (or its alias `example`) is then used to add the actual tests,
i.e. that's the equivalent to defining methods that start with `test_` in
Minitest.

Under the hood RSpec uses a lot of [metaprogramming](http://rubylearning.com/blog/2010/11/23/dont-know-metaprogramming-in-ruby/).
I.e. RSpec has methods that, when called, define code, classes and methods,
according to the arguments you pass. For example the code `describe User do ...
end` defines a class, and methods like `context`, and `it` add more code to
this class. RSpec then, eventually, executes this code automatically, and runs
your tests.

That means, even though you're very familiar with Ruby, you'll still need to
learn RSpec in order to use it effectively. That's one of the reasons why some
Ruby developers dislike RSpec: It's not "just Ruby" any more. On the flipside,
it's extremely powerful, and comes with features that no other testing library
has.

When you run the code in our `user_spec.rb` file, the output will look
something like this:

```
$ rspec user_spec.rb
.

Finished in 0.00204 seconds (files took 0.1559 seconds to load)
1 example, 0 failures
```

The dot indicates that there is exactly one test defined. RSpec calls tests
"examples". That's because they like to stress that tests shouldn't be so much
about technical details, but about the behaviour that the user cares about.
They like to say that we "specify" behaviour by the way of defining
"examples".

Let's break our test, and change the method `born_in_leap_year?` to always
return `false`:

```ruby
  def born_in_leap_year?
    false
  end
```

When you now run the code again the output will look like this:

```
$ rspec user_spec.rb
F

Failures:

  1) User born in 2000 is born in a leap year
     Failure/Error: expect(user.born_in_leap_year?).to eq true

       expected: true
            got: false

       (compared using ==)
     # ./user_spec.rb:25:in `block (3 levels) in <top (required)>'

Finished in 0.02033 seconds (files took 0.15813 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./user_spec.rb:23 # User born in 2000 is born in a leap year
```

Wow, that's pretty comprehensive. RSpec tells us exactly what's going wrong,
and where.
