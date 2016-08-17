# Testing via output

If you think back to the exercise to define a method `leap_year?` in the
[Ruby for Beginners](http://ruby-for-beginners.rubymonstas.org/exercises/methods_1.html)
book, a leap year is [defined](https://en.wikipedia.org/wiki/Leap_year#Algorithm)
as pseudo code like so:

```
if (year is not divisible by 4) then (it is a common year)
else if (year is not divisible by 100) then (it is a leap year)
else if (year is not divisible by 400) then (it is a common year)
else (it is a leap year)
```

Ok. You've implemented this method something like this:

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end
```

Now, how do you make sure the method does exactly what it is supposed to do?

While working through the exercises you've usually added code at the end of the
file that somehow exercised the methods written, and output results to the
terminal. You've then run the file, and inspected the terminal to see what the
result was.

So maybe you've had something along the lines of:

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end

puts "2001: #{leap_year?(2001)}"
puts "1900: #{leap_year?(1900)}"
puts "2000: #{leap_year?(2000)}"
puts "2004: #{leap_year?(2004)}"
```

And then you've run the code to see that the output actually is the expected
one:

```
2001: false
1900: false
2000: true
2004: true
```

This works well enough for exercises. However, if you write a bigger program
you don't really want all this output everytime the files are loaded, e.g. via
`require`.

Essentially, you'd want to separate your test code from the actual code, so
that tests are only run when you actually want them to run.

So what to do about that?


