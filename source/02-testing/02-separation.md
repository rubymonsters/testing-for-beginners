# Separating test code

Here's one trick that has been used a lot in early days of Ruby development:

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end

if $0 == __FILE__
  puts "2001: #{leap_year?(2001)}"
  puts "1900: #{leap_year?(1900)}"
  puts "2000: #{leap_year?(2000)}"
  puts "2004: #{leap_year?(2004)}"
end
```

If you store this code in a file `leap_year.rb` and execute it with `ruby
leap_year.rb` then you'll get the same output as above.

However, if you write a bigger program which requires this file by `require
"leap_year"` (so it can include your method definition, and use it somewhere
else) then you would not get this output.

You can try this out quickly on the command line:

```
$ ruby -r leap_year.rb -e "p leap_year?(1996)"
true
```

The flag `-r` tells Ruby to require your file. The flag `-e` tells it to
execute the given code. This way you don't have to create a new file in order
to try this out.

As you can see it now won't execute your "test", and thus won't output `2004:
true` again.

That is cool. We've just separated our test code from the implementation, i.e.
we can run the tests separately, if we want to. In turn it won't run the test
code when we just `require` the file, so we can use the method for something
else.

How does this work though?

The variables `$0` and `__FILE__` are rather arcane, and they were inspired by
other languages that existed when Matz designed Ruby in the 90s, especially
Perl, in this case.

The variable `$0` is a global variable (hence the dollar sign `$`) that holds
the name of the Ruby file that was given on the command line, as in `ruby
leap_year.rb`.

The varialbe `__FILE__` on the other hand is defined in every Ruby file, and
contains the file name of this exact file. If we execute `ruby leap_year.rb`
then these two names will be the same. If we execute any other ruby code that
requires the file `leap_year.rb` though, then they will not be the same.

We can further improve our test code by making it less repititive, and abstract
it:

```ruby
def leap_year?(year)
  year % 400 == 0 or year % 100 != 0 and year % 4 == 0
end

if $0 == __FILE__
  [2001, 1900, 2000, 2004].each do |year|
    puts "#{year}: #{leap_year?(year)}"
  end
end
```

Exercise: Try going to back to the [Ruby for Beginners](http://ruby-for-beginners.rubymonstas.org/)
book and add some tests to some of the exercises you made.
