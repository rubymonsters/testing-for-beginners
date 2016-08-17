# Test Classes

Ruby is an object-oriented programming language. So testing libraries often allow you
to implement your tests in the form of classes.

Let's write our own simple testing library.

Suppose we've stored the `leap_year?` method in a file `leap_year.rb`, and the
`User` class in a file `user.rb`.

We'd want the following code to work:


```ruby
require "date"
require "leap_year"
require "test"

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
  class UserTest < Test
    def test_not_born_in_leap_year_when_born_in_2001
      user = User.new("Jennifer", "2001-01-01")
      assert_false(@user.born_in_leap_year?)
    end

    def test_not_born_in_leap_year_when_born_in_1900
      user = User.new("Jennifer", "1900-01-01")
      assert_false(@user.born_in_leap_year?)
    end

    def test_born_in_leap_year_when_born_in_2000
      user = User.new("Jennifer", "2000-01-01")
      assert_true(@user.born_in_leap_year?)
    end

    def test_born_in_leap_year_when_born_in_2004
      user = User.new("Jennifer", "2004-01-01")
      assert_true(@user.born_in_leap_year?)
    end
  end

  test = UserTest.new
  test.run
end
```

The idea here is to represent each test with a method on a class. The method
should be as descriptive and readable as possible, and focus on the semantics,
instead of the implementation (i.e. what we test, not how we test).

However, this code will break, because the class `Test` does not exist. Also,
if you've followed our curriculum you'll spot a new thing here:

```
class UserTest < Test
```

What's that?

The `<` operator used here refers to a concept called "inheritance". It says:

*Define a new class `UserTest` and inherit all the methods from the class `Test`.*

In other words `UserTest` *is* a `Test`, but it also adds some extra stuff to it.

We can define the class `Test` like so, and store it to a file `test.rb`:

```ruby
class Test
  def run
    tests = methods.select { |method| method.to_s.start_with?("test_") }
    tests.each { |test| send(test) }
  end

  def assert_true(actual)
    assert_equal(true, actual)
  end

  def assert_false(actual)
    assert_equal(false, actual)
  end

  def assert_equal(expected, actual)
    if expected == actual
      puts "#{actual} is #{expected} as expected."
    else
      puts "KAPUTT! #{actual} is not #{expected} as expected."
    end
  end
end
```

Woha. That's a bunch of new stuff. If you don't grasp all of this don't worry,
it's certainly a level of Ruby knowledge you don't actually need this often.

Let's walk through it:

* Our class `UserTest` inherits all the methods from the class `Test`. So we
  can call the method `run` on it.

* The method `run` looks at all the `methods` defined on this object, and selects
  the method names that start with the string `test_`. So these must be the methods
  that we've defined on the class `UserTest`.

* It then, for each of these method names, calls `send` with the given method name.
  `send` calls this exact method on the object itself. That's right. `send` is
  an abstract way of calling a method: You hand it the method name you want to
  call, and it calls that method for you. So we call all the methods `test_not_born_in_leap_year_when_born_in_2001`,
  `test_not_born_in_leap_year_when_born_in_1900`, and so on.

* Now these methods set up a User object with the birthday we care about, and
  then call `assert_false` or `assert_true` with the actual that value the method
  `born_in_leap_year?` returned.

* The methods `assert_false` and `assert_true` just call `assert_equal`, passing
  the expected value, and the actual value they received.

Pretty cool.

However, we're now missing some important information. If you try breaking
the first test by changing `2001` to `2000` in the birthday (not the method
name), and run the output you'll see:

```
$ ruby -I . user.rb
KAPUTT! true is not false as expected.
false is false as expected.
true is true as expected.
true is true as expected.
```

Umm. We've lost the ability to easily identify which one of the test methods
broke. If we have a few hundred tests then counting them to figure out the
right one is not a cool option.

So how can we fix that?

We've previously passed in an identifier to `assert_equal` by calling
something like `assert_equal(expected, actual, "born_in_leap_year? for a User born on #{date}")`.

However, that requires us to type a lot of code everytime we want to call any
of our assertion methods.

Luckily, Ruby allows us to grab the so called backtrace at any point in our
code. The backtrace is the funny looking stuff that you see on any error message
in the console. It is an array of strings that tell which methods in which
files, and on which lines have been called so far, so we can "trace" the method
call back.

The method that lets us grab this backtrace is the method `caller`. Let's try
adding this line at the very top of our method `assert_equal`:

```
puts caller
```

When you run this code you'll see the backtrace printed, something like the
following:

```
$ ruby -I . user.rb
test.rb:16:in `assert_false'
user.rb:25:in `test_not_born_in_leap_year_when_born_in_2001'
test.rb:8:in `run_test'
test.rb:4:in `block in run'
test.rb:4:in `each'
test.rb:4:in `run'
user.rb:40:in `<main>'
```

Ok! So the backtrace that Ruby returns to us when we call `caller` includes
the method name that we are after. All we have to do is filter this array for
a line that includes `test_`, and then extract the method name from that line:


```ruby
class Test
  # ...

  def assert_equal(expected, actual)
    line = caller.detect { |line| line.include?("test_") }
    method = line =~ /(test_.*)'/ && $1
    if expected == actual
      puts "#{method} #{actual} is #{expected} as expected."
    else
      puts "KAPUTT! #{method} #{actual} is not #{expected} as expected."
    end
  end
end
```

If the code `line =~ /(test_.*)'/ && $1` on the second line looks confusing to
you, this is a regular expression that grabs the method name from the line in
the backtrace:

The expression says "Find a string that starts with `test_`, and then include
all characters until you find a single quote `'`. Grab all these characters
including `test_`, but do not include the single quote.

The special variable `$1` will then include the characters matched by the
regular expression.

And with this change we've got our method names back, even though we didn't
have to pass them to our assertion methods in each of our tests:

```
KAPUTT! test_not_born_in_leap_year_when_born_in_2001 true is not false as expected.
test_not_born_in_leap_year_when_born_in_1900 false is false as expected.
test_born_in_leap_year_when_born_in_2000 true is true as expected.
test_born_in_leap_year_when_born_in_2004 true is true as expected.
```

Testing libraries come, essentially, with code like this. They define classes
and methods that make it easy for you to, as much as possible, focus on what
you want to test, and not to bother with the question how to write these tests.

Let's make one more tiny improvement, similar to what such testing libraries do:

Let's try to remove the two extra lines for instantiating our test class and
calling `run` on it:

```ruby
  test = UserTest.new
  test.run
```

We've just defined a test class, and, in this context, we can be fairly certain
that we want to run these tests, right? So not having to type these lines would
be kinda useful. Ruby could just automatically create an instance of the class
and call `run` on it whenever we define a class that inherits from `Test`.

How can we do that?

First of all we'd want a way to find out all subclasses that have inherited from
the class `Test`. Ruby, starting with the version 3, will have a native way to
do that with the [method `subclasses`](http://apidock.com/rails/v3.2.13/Class/subclasses).

In earlier versions of Ruby, we need to add this ourselves:

```ruby
class Test
  class << self
    def inherited(subclass)
      subclasses << subclass
    end

    def subclasses
      @subclasses ||= []
    end
  end

  # ...
end
```

The method `inherited` is called by Ruby every time the class is inherited, passing
the inheriting class (i.e. in our case the class `UserTest`). We keep track of all
these classes in the array that is stored on the instance variable `@subclasses`.

Now, how can we automatically run these tests?

There's another little trick that is so rarely used in day-to-day programming that
many Ruby programmers don't even know about it. You can tell Ruby to execute code
before it exits (i.e. terminates the program). And this is exactly what we want
to do, isn't it?

Here's how:

```ruby
at_exit do
  Test.subclasses.each do |subclass|
    test = subclass.new
    test.run
  end
end
```

The method `at_exit` takes a block that is called an "exit hook". I.e. we tell
Ruby to (right before Ruby terminates the program, and "exits") execute the
block that we've hooked up.

In this block we take each of the subclasses of the class `Test` (in our case
that is going to be just one class, the class `UserTest`), instantiate it,
and call `run` on the instance.

Pretty neat. We've essentially implemented a really small, but actually useful
testing library ourselves, with just 45 lines of Ruby.

Let's look at some real world testing libraries next.

