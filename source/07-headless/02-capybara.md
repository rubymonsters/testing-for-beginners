# Capybara

*A DSL for testing web applications*

Now, we want to test a Ruby application, and we don't really want to write
a lot of Javascript code in order to do so.

And the Javascript code we would have to write actually is quite a bit of a
hassle, unless we use a bunch of libraries. For example, it's not even very
easy to click on a link in a browser through plain Javascript. That's because
the document object model (DOM), as defined by the W3C is quite an odd
construct.

The code for clicking on a link might look something like this:

```javascript
var element = document.querySelector("a[href='/location.html']");
var event = document.createEvent("MouseEvents");
event.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
element.dispatchEvent(event);
```

That's right. One does not just "click". One creates a mouse event, sets it up
with tons of options, and then "dispatches" it on the element.

Luckily there are Ruby libraries to help with this kind of stuff. The probably
most widely used one is [Capybara](http://jnicklas.github.io/capybara/).

That's right. Capybara maybe has the most badass mascot animal of all open
source libraries.

It also defines a [DSL](https://github.com/jnicklas/capybara#the-dsl) for
describing interactions with web pages. The DSL includes handy methods such
as:

```ruby
visit "/members"                # go to a URL
click_on "Add member"           # click on a link
fill_in "Name", with: "Monsta!" # fill in a form field
click_on "Submit"               # submit the form
```

Now that looks a little more handy.

With Capybara you can easily inspect the HTML of a page, find elements
(remember how we added another gem `rspec-html-matchers`? Capybara brings
similar functionality), interact with the page by clicking around, filling in
form fields, submitting forms etc. You can also evaluate Javascript on the page
(in order to simulate certain things), work with native browser alert windows,
and a lot more. You can even take screenshots, even though there's no browser
window.

How does Capybara know how to talk to Phantom.js though?

As mentioned there are a lot of different headless browsers, and Capybara can
talk to some of them. In order to do so Capybara uses "drivers". And the driver
for talking to Phantom.js is called [Poltergeist](https://github.com/teampoltergeist/poltergeist),
because a name like `CapybaraPhantomjsDriver` would have been too boring.

Anyway, we want to install both gems:

```
$ gem install capybara poltergeist
```

Let's try it out!

Create a file `capybara.rb` and add the following:

```ruby
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist

browser = Capybara.current_session
browser.visit 'http://rubymonstas.org'
puts browser.html
```

Awesome. Again, that prints out the HTML of our homepage.

Now, let's click on a link:

```ruby
browser = Capybara.current_session
browser.visit 'http://rubymonstas.org'
browser.click_on 'Ganz oben office'
puts browser.text
```

That prints out:

```
Where we meet How to get to the office space where we meet (the former Travis CI office).
...
```

As you can see we've successfully navigated to another page, and now look at
the plain text of that other.

If we want to make our test not depend on the link text (because that might
change at any time) then we can also use XPath or CSS [selectors](http://ejohn.org/blog/xpath-css-selectors/).

CSS selectors are a little more common because many developers already know
them from CSS and Javascript (e.g. JQuery). XPath selectors on the other hand
are even more powerful.

For example, this CSS selector says "select the `a` tag that has the attribute
`href="/location.html"`.

```ruby
browser.find('a[href="/location.html"]').click
```
