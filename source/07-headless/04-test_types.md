# Types of tests

TBD

## One assertion per test

You may have noticed that our tests so far, ever since we've written our own
little `Test` class, had followed a certain rule: Every test tested one single
thing. For example in the RSpec tests that test the `User` class, and it's
`born_in_leap_year?` method every test tests the return value of that method in
a given context. That's one assertion per test.

Now with Capybara we have tested things by the way of using them, and then,
eventually, made some assertions about the resulting page.

For example, we make sure that a certain link is there by the way of clicking
it, not using an actual assertion method. We then made sure that a certain
input field with a label tag was on the page, by the way of filling it in.
So while we were using the page we have made assumptions about the elements
on the page.

This way we've made several assertions in one single test.

## Using stubs vs real resources


