# Advanced Usage

RSpec comes with a lot of well-thought-out features that allow us to write very
descriptive, succinct, and concise tests that focus on the few things we really
care about.

So far, our tests, using the most basic style, look something like this:

```ruby
describe User do
  context "born in 2001" do
    it "is not born in a leap year" do
      user = User.new("Francisca", "2001-01-01")
      expect(user).not_to be_born_in_leap_year
    end
  end

  context "born in 1900" do
    it "is not born in a leap year" do
      user = User.new("Francisca", "1900-01-01")
      expect(user).not_to be_born_in_leap_year
    end
  end

  context "born in 2000" do
    it "is born in a leap year" do
      user = User.new("Francisca", "2000-01-01")
      expect(user).to be_born_in_leap_year
    end
  end

  context "born in 2004" do
    it "is born in a leap year" do
      user = User.new("Francisca", "2004-01-01")
      expect(user).to be_born_in_leap_year
    end
  end
end
```

As you see we keep repeating the setup in the first line of every test.
Wouldn't it be nice to move this to a shared place, like Minitest's `setup`
method?

## Before

RSpec has the same feature, but it calls it `before`.

This is just another method that RSpec defines, and it takes a block, too.
RSpec will call (execute) this block before each one of the tests (examples):


```ruby
describe User do
  before { @user = User.new("Francisca", "2001-01-01") }

  context "born in 2001" do
    it "is not born in a leap year" do
      expect(@user).not_to be_born_in_leap_year
    end
  end

  context "born in 2000" do
    it "is born in a leap year" do
      expect(@user).to be_born_in_leap_year
    end
  end
end
```

Our `before` block sets up an instance variable `@user` so that our test then
can use it. That's cool.

However, we now have a problem: The hard-coded birthday is specific to the first
context, and should be different for each one of our contexts, because that's
the one single piece of data that changes. The second test would use the wrong
year, and therefore fail, because it would use a user that is actually born in
`2000`, not `2001`, despite what the context desciption tells.

So how do we fix that?

## Let

RSpec comes with another feature to help with this: the method `let` allows us
to define such bits of data (or more precisely, objects) that need to be
specified per context. Here's how that looks like:


```ruby
describe User do
  before { @user = User.new("Francisca", "#{year}-01-01") }

  context "born in 2001" do
    let(:year) { 2001 }

    it "is not born in a leap year" do
      expect(@user).not_to be_born_in_leap_year
    end
  end

  context "born in 2000" do
    let(:year) { 2000 }

    it "is born in a leap year" do
      expect(@user).to be_born_in_leap_year
    end
  end
end
```

This fixes our problem, and these tests pass.

Essentially, `let` is a method that defines another method with the given name,
in our case `year`. This method then can be used in other places, such as the
`before` block, or our tests (`it` blocks).

Instead of using the rather generic `before` block, and instance variables, we
can also use `let` to setup the user:

```ruby
describe User do
  let(:user) { User.new("Francisca", "#{year}-01-01") }

  context "born in 2001" do
    let(:year) { 2001 }

    it "is not born in a leap year" do
      expect(user).not_to be_born_in_leap_year
    end
  end

  context "born in 2000" do
    let(:year) { 2000 }

    it "is born in a leap year" do
      expect(user).to be_born_in_leap_year
    end
  end
end
```

This actually is a pretty common way of writing RSpec tests.

The `let(:user)` statement defines the `user`, and as you can see, this
statement is common to both contexts: they both use `user`.

The `let(:year)` statements however, are specific to the contexts, and define
the `year` for each one of the contexts.

## Subject and Should

Now `user` is the object under test, and it is an instance of the class `User`
which is already mentioned in the `describe` statement. So, in a way, this is
a little repetitive.

Because this is such a common pattern, RSpec comes with another feature to make
this a little more concise, and remove this repetition: `subject`. We can use
it like so:

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2000" do
    let(:year) { 2000 }

    it "is born in a leap year" do
      expect(subject).to be_born_in_leap_year
    end
  end
end
```

And because `subject`, semantically, is the thing we want to test, RSpec also
defines a shorthand for `expect(subject).to` that we can use if we have a
`subject` defined: `should`. That makes our code even more concise:

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2000" do
    let(:year) { 2000 }

    it "is born in a leap year" do
      should be_born_in_leap_year
    end
  end
end
```

This works great. And we've reduced the amount of code we have to type by
a great deal.

However, what's with the duplication in the `it` message, and the actual code
that implements our expectation?

## Anonymous it

The lines `it "is born in a leap year"` and `should be_born_in_leap_year`
pretty much describe the same thing, don't they?

RSpec allows us to omit the message passed to `it` and simply put the
whole test on one line, like so:

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2000" do
    let(:year) { 2000 }
    it { should be_born_in_leap_year }
  end
end
```

Whoa.

Let's apply this to all of our tests.

We can implement the same test case we've had before (at the beginning of this
chapter) like this, using all the advanced features we've just learned:

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2001" do
    let(:year) { 2001 }
    it { should_not be_born_in_leap_year }
  end

  context "born in 1900" do
    let(:year) { 1900 }
    it { should_not be_born_in_leap_year }
  end

  context "born in 2000" do
    let(:year) { 2000 }
    it { should be_born_in_leap_year }
  end

  context "born in 2004" do
    let(:year) { 2004 }
    it { should be_born_in_leap_year }
  end
end
```

You decide which one you like better.

The output will look a wee bit different, but just as readable, even though we
haven't written out the extra description on the `it` block:

```
$ rspec --format doc user_spec.rb

User
  born in 2001
    should not be born in leap year
  born in 1900
    should not be born in leap year
  born in 2000
    should be born in leap year
  born in 2004
    should be born in leap year

Finished in 0.00462 seconds (files took 0.1464 seconds to load)
4 examples, 0 failures
```

To summarize, the extra features used are:

* `let` allows you to dynamically define a method that will return the given
  value. We use this to define the only varying bit of data: the `year`.
  It is important to note that `let` memoizes the result. I.e. it only calls
  the block once. Also, it only executes the block when you actually call it.
* `subject` is a convenience helper that lets us specify the "thing" that
  is under test. In our case that's a `User` instance. `subject` also memoizes
  the result. And just like `let`, it also only executes the block when you
  actually call it.
* `should` assumes that we want to test the `subject`. It is a shorthand for
  `expect(subject).to` (while `should_not` is the corresponding shorthand for
  `expect(subject).not_to`).

This style lets us reduce the amount of code that we need to type (and read)
significantly.

The first version ("basic style") of our tests had 715 characters on 29 lines.
This new version has 474 characters on 23 lines. That's a massive reduction
(~30% less characters to type and read), and allows us to focus much more on
the relevant differences.

However, it also requires for us to learn these RSpec features, and get
familiar with how to implement and understand such tests properly.

