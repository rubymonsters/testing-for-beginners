# Computed tests

What if you have lots and lots of methods in lots of classes, and you want to
make changes to them? You'd need to output a lot of things, and inspect them
very carefully, in order not to miss any mistakes.

In the example above you'd have to remember that your code is valid if it
outputs `false` for the first two years, and `true` for the last two ones.
That's a lot of knowledge to keep in mind for just one method. Imagine you'd
have hundreds of methods. You'd need to very carefully inspect a lot of output.

Isn't that what computers are there for? Doing all the tedious, mechanical work
for us that requires a lot of precision?

Let's see. What if we, instead of outputting plain values to the terminal, also
output a hint if this is the value that we expected to see?

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end

if $0 == __FILE__
  data = {
    2001 => false,
    1900 => false,
    2000 => true,
    2004 => true
  }

  data.each do |year, expected|
    actual = leap_year?(year)
    if expected == actual
      puts "leap_year?(#{year}) returned #{actual} as expected."
    else
      puts "KAPUTT! leap_year?(#{year}) did not return #{expected} as expected, but actually returned #{actual}."
    end
  end
end
```

This will output:

```
leap_year?(2001) returned false as expected.
leap_year?(1900) returned false as expected.
leap_year?(2000) returned true as expected.
leap_year?(2004) returned true as expected.
```

Let's try breaking our method by always returning `true`:

```ruby
def leap_year?(year)
  true
end
```

We'll then get:

```
KAPUTT! leap_year?(2001) did not return false as expected, but actually returned true.
KAPUTT! leap_year?(1900) did not return false as expected, but actually returned true.
leap_year?(2000) returned true as expected.
leap_year?(2004) returned true as expected.
```

That's much better, isn't it? Even if you'd have hundreds of tests (many
real-world applications do have thousands) it would be pretty easy to spot
any broken behavior, right?
