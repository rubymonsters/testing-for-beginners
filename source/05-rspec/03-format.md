# Format

Let's add a few more tests first, and complete the four cases for the
`leap_year?` logic:

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

When we run this we'll get the following output:

```
$ rspec user_spec.rb
....

Finished in 0.00632 seconds (files took 0.15438 seconds to load)
4 examples, 0 failures
```

That's nice. Each dot represents an executed test, and we get a pretty summary.
For large test suites this is the most useful output format.

We only have a few tests, though. Let's try turning on RSpec's documentation
format by passing the command line option `--format doc`. With all
tests passing the output will look like this:

```
$ rspec --format doc user_spec.rb

User
  born in 2001
    is not born in a leap year
  born in 1900
    is not born in a leap year
  born in 2000
    is born in a leap year
  born in 2004
    is born in a leap year

Finished in 0.00398 seconds (files took 0.15358 seconds to load)
4 examples, 0 failures
```

That's pretty awesome, isn't it?

Our test output reads like documentation, and tells exactly what behaviour we
expect.
