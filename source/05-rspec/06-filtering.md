# Filtering

One other great feature of RSpec is that it allows us to specify which tests we
want to execute.

Remember the test output when we made our specs fail before?

It ended with something like this:

```
Failed examples:

rspec ./user_spec.rb:28 # User born in 2001 should not be born in leap year
```

The bit `:28` at the end of the filename means "line 28". So this is how we can tell RSpec to
execute one single test only, and it even outputs the command we need to run to
the test output for our convenience. In order to re-run the test that has
failed, we can copy and paste this command from the output.

That is really convenient if you have a big test suite and your tests are
rather slow. So, while working on fixing a certain bug you'd only want to
run this one failing test.

You can also run groups of tests: E.g. you can run all tests in the first
`context` by adding the line that `context` statement sits on. In my case
that's line `25`, so this command runs all tests in the first context:

```
$ rspec --format doc ./user_spec.rb:25
Run options: include {:locations=>{"./user_spec.rb"=>[25]}}

User
  born in 2001
    should be named "Francisca"
    should not be born in leap year

Finished in 0.00237 seconds (files took 0.15871 seconds to load)
2 examples, 0 failures
```

That's pretty handy.

RSpec has more such features that allow you to run your tests selectively. For
example you can tag contexts and tests, and then specify certain tags when
running your tests.
