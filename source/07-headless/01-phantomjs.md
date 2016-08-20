# Phantom.js

*Headless browers*

In order to install Phantom.js download it from their website [here](http://phantomjs.org/download.html).

On Windows the download page says that `phantomjs.exe` should be ready use
once you've run the installer.

On Mac OSX and Linux you'll need to download and extract the zip file, move the
contents to a proper place, and make the binary (executable, command line app)
available in your PATH (that's a variable that tells the system where to look
for binaries (command line apps).

Here's one way to do that:

Download and the zip file for your operating system. On Mac OSX it would end
up in a the `~/Downloads` directory, so you can go there and expand the zip
file by double clicking it.

At the time of this writing the current version is `2.1.1`, and it is included
in the directory name. So we're going to use `~/Downloads/phantomjs-2.1.1-macosx`
in this example. You'll need to use the version number and operating system
name that you have.

Now in your terminal copy it to a proper place. One good location is `/usr/local`:

```
$ sudo cp ~/Downloads/phantomjs-2.1.1-macosx/bin/phantomjs /usr/local/bin
```

`sudo` might not be necessary, e.g. if you're using Homebrew. But on many
systems it will be. `sudo` will ask you for your computer's password, enter it,
and hit return.

Once you've successfully installed `phantomjs` your system should find it
when you run:

```
$ which phantomjs
/usr/local/bin/phantomjs
```

If that outputs `phantomjs not found` you've made a mistake.

## Trying out Phantom.js

Now let's try to do something with it.

Phantom.js wants us to use Javascript. So let's create a file `monstas.js`
and add the following code:

```javascript
console.log('Hello Ruby Monstas!');
phantom.exit();
```

Save that file and run it with phantom.js in the terminal like so:

```
$ phantomjs monstas.js
Hello Ruby Monstas!
```

On my computer that hangs for a brief moment, but then executes the Javascript
code and prints out the message.

That's kinda cool, isn't it? We've just uses a browser to run some Javascript
and print something to the Javascript console (which gets printed to our
terminal because there's no browser window).

Let's try browsing to an actual website.

Change the code in the file `monstas.js` like so:

```javascript
 var page = require('webpage').create();
 page.open('http://rubymonstas.org/', function(status) {
   console.log(page.plainText);
   phantom.exit();
 });
```

When you run this it will output the plain text from our website, with all
HTML tags removed:

```
$ phantomjs monstas.js
Ruby Monstas

Ruby Monstas stands for (Berlin) Ruby Monday Study Group’stas, and this is our homepage.

We are one of many project groups in the Berlin Rails Girls community, some of which can be found here.

We meet every Monday at 7pm at the Ganz oben office (the office on the very top floor).
```

Hah! How cool is that. We can write some Javascript code that, when run on the terminal
will actually browse to a website, fetch the response, and display the text.

Let's try outputting the actual HTML:

```javascript
 var page = require('webpage').create();
 page.open('http://rubymonstas.org/', function(status) {
   console.log(page.content);
   phantom.exit();
 });
```

And run it:

```
$ phantomjs monstas.js
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Ruby Monstas</title>
    <link href="/styles.css" rel="stylesheet" type="text/css">
  </head>

  <body id="index" class="">
    <article class="paper">
      <h1 id="ruby-monstas">Ruby Monstas</h1>
        <p>Ruby Monstas stands for <em>(Berlin) Ruby Monday Study Group’stas</em>, and this is
        our homepage.</p>
        ...
```

Wohoo! Very cool.

We can see the full HTML just like we saw it in our Rack::Test based tests.
So we could now run some assertions against it, and test the website.

This is roughly how testing a web application using a headless browser works.

* Instead of navigating to an external website (like our homepage) you'd
  navigate to the app that is started locally, just like you'd start it when
  you navigate around during development.
* Instead of manually typing Javascript we use another Ruby library in order
  to talk to Phantom.js and instruct it to do the things that we want to test.
* We can then inspect the resulting website, and see if the HTML elements that
  we expect are there. Except this time (unlike Rack::Test based tests) we'd
  see the output that the browser actually displays, including Javascript and
  CSS applied.

Does that make sense?





















