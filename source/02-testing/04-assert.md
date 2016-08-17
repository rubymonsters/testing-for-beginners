# Assertions

Testing libraries provide a lot of tools to make writing tests easier, and we'll look
at two of the most common ones in a bit.

In order to get even closer to what real testing libraries look like we could
extract a method `assert_equal`, like so:

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
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
    2001 => false,
    1900 => false,
    2000 => true,
    2004 => true
  }

  data.each do |year, expected|
    actual = leap_year?(year)
    assert_equal(expected, actual, "leap_year?(#{year})")
  end
end
```

Our method `assert_equal` outputs directly to the terminal, which, in our case,
is good enough.

This is pretty cool!

With just plain Ruby we've written some useful tests that only will be executed
if we want them to, and our actual test code now looks much more focussed. The
method `assert_equal` could be defined somewhere else, in an external file, so
we could reuse it in other places.

You could imagine writing lots of methods, and adding tests to them so that,
whenever you or fellow developers change something about them your tests would
catch any mistakes.

