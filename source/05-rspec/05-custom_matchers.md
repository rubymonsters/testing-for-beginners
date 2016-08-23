# Custom Matchers

We've talked a bit about matchers before, and briefly mentioned that RSpec
even allows us to define our own custom matchers.

Let's have a quick look at this.

Here is the code that we have so far:

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

Now, what if we want to specify (test) the `name` method?

We could simply add the following test, using the basic style:

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2001" do
    it "returns the name" do
      expect(subject.name).to eq "Francisca"
    end

    it { should_not be_born_in_leap_year }
  end
end
```

However, we'd mix styles here. That's not a bad thing, really! But wouldn't it
be cool if we could say this instead?

```ruby
describe User do
  subject { User.new("Francisca", "#{year}-01-01") }

  context "born in 2001" do
    let(:year) { 2001 }
    it { should be_named("Francisca") }
    it { should_not be_born_in_leap_year }
  end
end
```

If we were to execute this, RSpec would try to call the method `named?` on our
`User` instance (just like `be_born_in_leap_year` calls `born_in_leap_year?` on
the user), and that method does not exist. We could add that method `named?` to
our `User` class, but we don't really want to add any such methods to our real
code, just so we can make the tests prettier.

Instead, we can define a [custom matcher](https://www.relishapp.com/rspec/rspec-expectations/v/2-4/docs/custom-matchers/define-matcher)
`be_named` that inspects the user's `name`:

```ruby
RSpec::Matchers.define(:be_named) do |expected|
  match do |object|
    object.name == expected
  end
end
```

Hmmmm, ... apparently a matcher is a block that calls a method `match` that
takes another block. The actual and expected values are passed as arguments to
the two blocks, somehow. Inside the inner block we are supposed to return
`true` or `false` depending if the matcher is supposed to "match".

Ok, well, we don't really have to understand how exactly this works in 
detail—we can just slap it at the end of our file, and run it:

```
$ rspec --format doc user_spec.rb

User
  born in 2001
    should be named "Francisca"
    should not be born in leap year

Finished in 0.00267 seconds (files took 0.15704 seconds to load)
2 examples, 0 failures
```

Yay!

Now, how cool is that.

With those five lines of Ruby code we've extended RSpec to include a matcher
that is pretty specific to our code. And now we can use the advanced style
in order to test our `name` method.
