# Matchers

We've discussed how methods such as `describe`, and `context` are used to set
up a structure for our tests, and how `it` adds an actual test ("example") to
it.

What about the implementation of the test, though?

Let's look at our code again:

```ruby
user = User.new("Francisca", "2000-01-01")
expect(user.born_in_leap_year?).to eq true
```

What does `expect` do, exactly? And what's the deal with `to` and `eq`?

These also are methods that RSpec defines for us, so we can describe our
expectations in a readable way. That is to say, these methods are RSpec's equivalent to
assertions (`assert` and friends) in Minitest.

Technically, `expect` returns an object that responds to the method `to`. This
method `to` expects to be passed an object that is a so-called matcher. It will
then call the matcher to see if it ... well, matches.

Remember that in Ruby you can omit parentheses when calling a method (as long as this doesn't make your code ambiguous). So we
could just as well add them:

```ruby
expect(user.born_in_leap_year?).to(eq(true))
```

The method `eq` returns an RSpec matcher that simply tests if the object passed
to `expect` is equal to the object passed to `eq`. This may sound more
complicated than it is.

If you have a look at the [documentation](https://relishapp.com/rspec/rspec-expectations/v/3-5/docs/built-in-matchers)
there are lots and lots of matchers pre-defined, and RSpec makes it easy to
define your own matchers, too.

For example:

```ruby
expect(10).to be > 5
expect([1, 2, 3]).to include 1
expect("Ruby Monstas").to start_with "Ruby"
```

No matter exactly how the code that implements these methods `expect`, `to`,
and, for example, `eq` or `start_with` works: the purpose is to allow for
code that kinda reads like an English sentence. You'll get used to these pretty soon, once
you've started writing some RSpec tests.

Essentially, you start with `expect(whatever_thing_to_test).to`, and then you find
a matcher that works. `eq` is always a good start. So you end up with:

```ruby
expect(whatever_thing_to_test).to eq whatever_you_expect
```

For example:

```ruby
expect(your_object.some_method_to_test).to eq "the concrete value that you expect to be returned"
```

Does that make sense?

Cool. Let's have a look at another badass feature RSpec comes with.

## Magic matchers

RSpec also allows you to use matchers that depend on the methods defined on the
object passed.

Wait, what?

Yeah.

Here's a simple example:

```ruby
expect(nil).to be_nil
```

The matcher `be_nil` expects the method `nil?` to be defined on the object
under test, i.e. the object `nil`. As a matter of fact, the method `nil?` *is*
defined on every object in Ruby. And in our case, `nil.nil?` returns true, of
course, so the test would pass.

This test, however, would not pass:

```ruby
expect(true).to be_nil
```

Because `true.nil?` returns false.

Now, our `User` instances respond to the method `born_in_leap_year?`. Therefore
RSpec allows us to use a matcher `be_born_in_leap_year`:

```ruby
user = User.new("Francisca", "2000-01-01")
expect(user).to be_born_in_leap_year
```

Whoa.

RSpec sees that we're calling the method `be_born_in_leap_year` and it figures
"Ok, that must mean that the call `user.born_in_leap_year?` must return true.

Such "magic" methods are another meta-programming technique that RSpec leverages
here. Usually they're pretty debatable, and often not a great choice. However,
in this case, they allow adding this very cool feature to RSpec.

## Negating matchers

What if we want to specify that a user is *not* born in a leap year, though?
In other words, if we want to negate our expectation?

RSpec allows us to simply invert a matcher by using the method `not_to` as
opposed to `to`:

```ruby
  expect(user).to be_born_in_leap_year # vs
  expect(user).not_to be_born_in_leap_year
```

This works for all other matchers, too, of course - and `to_not` can be used interchangeably with `not_to`:

```ruby
  expect(1).to eq 1
  expect(2).not_to eq 3

  expect(true).to be true
  expect(false).not_to be true

  expect([1, 2, 3]).to include 1
  expect([1, 2, 3]).to_not include 9

  expect("Ruby Monstas").to start_with "Ruby"
  expect("Ruby Monstas").to_not start_with "Java"
```

And so on.

## Simple expectations

If all this matcher business seems too complicated to you for now, you can also
always fall back to simply comparing actual and expected values like so:

```ruby
user = User.new("Francisca", "2000-01-01")
actual = user.name
expected = "Francisca"
expect(actual).to eq expected
```

Or:

```ruby
user = User.new("Francisca", "2000-01-01")
actual = user.born_in_leap_year?
expected = true
expect(actual).to eq expected
```

That's some more code to type, but doing that sometimes helps RSpec beginners to
understand what's going on better.
