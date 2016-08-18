# Minitest

[Minitest](https://github.com/seattlerb/minitest) is a library that has been
developed by the (some might say, infamous) Settle Ruby community.

It has replaced the much older, and much more clunky original `test/unit`, a
library that used to be included in Ruby's standard library. Nowadays, Ruby
ships with the more modern, and more extensible, Minitest, so you can simply
require it, and you're good to go, you can start writing tests.

Minitest works much like our little `Test` library. Here's their synopsis
from their [README](https://github.com/seattlerb/minitest#synopsis), a little
reduced.

Given that you'd like to test the following class:

```ruby
class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end
end
```

Define your tests as methods beginning with `test_`:

```ruby
require "minitest/autorun"

class TestMeme < Minitest::Test
  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end
```

As you can see there's a method `setup`. This method will be called before each
of the test methods. This makes sense if you think about the [stages](/testing/stages.html)
that tests usually include: you want setup to be run first, before each of the
tests.

Check out their documentation on what [assertions](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)
are defined. There are `assert`, and `assert_equal`, much like the methods
that we've defined before. But there also are a lot more useful methods, and
most of them come with a counterpart method `refute` (fail if truthy, while
`assert` fails if falsy).

Try to translate some of our manual tests in the chapter [testing](/testing.html)
to Minitest.

In order to do so create a file that has your code (e.g. the method `leap_year?`),
and then defines a class, e.g. `LeapYearTest` that inherits from `Minitest::Test`.
You'll also want to `require "minitest/autorun"` at the very top of that file.

Also consider finding other code in the [Ruby for Beginners](http://ruby-for-beginners.rubymonstas.org/)
book that looks like it shold be tested, and try writing some tests for it.

