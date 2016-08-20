# Headless browsers

A so called headless browser is a full featured browser that can be started
on the command line, and behaves just like any other browser, but simply does
not come with a browser window.

Most importantly, it can be used programmatically: You can write code that asks
this browser to navigate to a certain page, click on a link, submit a form, and
so on.

This is cool because so far we've completely ignored that our web application
might include things like Javascript code, or CSS that hides certain elements
from the page, and only reveals them when the user does something.

Headless browsers can be used to test the user's experience in a more complete
way.

Rack::Test based tests (and friends, there are other libraries that do similar
things) simply instantiate the application, run a fake request against it, and
then inspec the response. This works great for simple applications like our
Sinatra app.

However, this approach also does not really test the "full stack". E.g. it
ignores that the user's browser might alter the page in some way, like, through
Javascript or CSS.

Headless browsers allow us to write full stack tests. These tests tend to be a
little slower, and potentially more brittle. But they're a great tool to have
on your belt as a developer.

There are several [headless browsers](https://github.com/dhamaniasad/HeadlessBrowsers)
out there, and their quality isn't always the greatest.

The most popular ones probably are [Selenium](http://docs.seleniumhq.org/)
(which has become a little dusty these days), and [Phantom.js](http://phantomjs.org/)
(which is pretty modern, and stable).

So, let's have a look at [Phantom.js](http://phantomjs.org/) next.

