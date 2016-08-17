# Stages of a test

There are three stages in most tests, and we want to introduce them early so
you recognize them later.

Let's assume you've stored the `leap_year?` method in a file `leap_year.rb`,
and you have another file `user.rb` that looks like this:


```ruby
require "leap_year"
require "date"

class User
  def initialize(name, birthday)
    @name = name
    @birthday = birthday
  end

  def born_in_leap_year?
    leap_year?(Date.parse(@birthday).year)
  end
end

if $0 == __FILE__
  def assert_equal(expected, actual, method)
    if expected == actual
      puts "#{method} returned #{actual} as expected."
    else
      puts "KAPUTT! #{method} did not return #{expected} as expected, but actually returned #{actual}."
    end
  end

  data = {
    "2001-01-01" => false,
    "1900-01-01" => false,
    "2000-01-01" => true,
    "2004-01-01" => true
  }

  data.each do |date, expected|
    user = User.new("Jennifer", date)
    actual = user.born_in_leap_year?
    assert_equal(expected, actual, "born_in_leap_year? for a User born on #{date}")
  end
end
```

As you can see our tests now have three stages:

1. We first set up an object that we want to test with a certain birthday: `User.new("Jennifer", date)`.
2. We then call the method we're interested in: `user.born_in_leap_year?`.
3. And finally we assert that the result actually is the expected result.

These three stages often can be found in tests:

1. Setup
2. Execution
3. Assertion

In a web application, for example, the setup stage could mean that we store
certain data in the database. In the execution stage we then make a request to
the application. E.g. we'd `GET` a list, or we'd `POST` a new entry.  In the
assertion stage we'd then assert (make sure) that we get the expected result.
E.g. if we've used `GET` we'd inspect the returned HTML to see if the expected
entries are listed. Or if we've used `POST` to create a new entry we might look
at the database to see if the record actually has been created.
