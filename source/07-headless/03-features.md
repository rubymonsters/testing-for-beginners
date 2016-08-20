# Feature tests

*Telling user stories*

Tests that use Capybara or similar libraries, and tests that use a headless
browser, often have a slightly different format from the tests that we've
written so far.

These tests tell stories per test, they explain the features that our app has,
and that our users care about.

For example, for our `members` app, we explain:

When I go to the members list, click the link "New member", fill in the name,
and click submit, then I want the member details page for this new member to be
shown, with a confirmation message.

This is also called a user story. Tests that implement such stories are called
feature tests. [1]

We'll write some feature tests for our `members` app, and then later discuss
the differences to the Rack::Test based tests that we've written for this app
before.

## Specification

Let's write down our user stories first.

This way we can focus on them, and figure out the implementation later. Also,
we'll know exactly how much work we still have in front of us.

* Listing all members: When I go to the members list then I want to see a list
  of all members, linking to their details page, and links to edit and remove
  the member.

* Showing member details: When I go to the members list, and I click on a
  member name, then I want the member's details page to be shown, displaying
  their name.

* Creating a new member: When I go to the members list, click the link "New
  member", fill in the name, and click submit, then I want the member details
  page for this new member to be shown, with a confirmation message.

* Editing a member: When I go to the members list, click the "Edit" link for a
  member, change their name, and click submit, then I want the member details
  page for this member to be shown, displaying their new name, with a
  confirmation message.

* Removing a member: When I go to the members list, click the "Remove" link
  for a member, and confirm, then I want the members list to be shown, with
  the member removed, and a confirmation message.

Does this make sense?

We think this describes the functionality of our little application fairly
well, from the perspective of a user.

And unsurprisingly we have 5 stories. These correspond to the 5 groups of
routes on a typical [resource](http://webapps-for-beginners.rubymonstas.org/resources/groups_routes.html).

## Test setup

Ok, let's get started.

We'll want our `spec_helper.rb` file to look like this. For now you can also
just stick it to the top of your test file. Let's call it `feature_spec.rb`.

```ruby
require "app"
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.app = proc { |env| App.new.call(env) }

RSpec.configure do |config|
  config.include Capybara::DSL
end
```

As you can see we need to require both Capybara's DSL and the Poltergeist
driver. We then tell Capybara to use Poltergeist as a driver, and tell RSpec to
include the DSL into our tests, so we can use these methods.

The line `Capybara.app = proc { |env| App.new.call(env) }` tells Capybara
how to call our app. This is the equivalent of the `let(:app)` statement in
our Rack::Test based tests: The test libararies we use do not know about
our app, and how to create or call it, so we have to tell them.

Also, while we're at it, let's make sure our `members.txt` file does not
leak state again, and add this to our configuration:

```ruby
  config.before { File.write("members.txt", "Anja\nMaren\n") }
```

We've had this in a `before` block in our tests before. Moving it to our
general RSpec configuration is a sensible choice, too. This way we make
sure that we don't forget about it.

## Test implementation

Ok, now we're ready to write our first feature test.

Remember how we've used `browser.visit` when we played with Capybara?
The Capybara DSL that we've included to our RSpec tests allows us to
just directly call these methods without using `browser`:

```ruby
describe App do
  let(:links) { page.all('li').map { |li| li.all('a').map(&:text) } }

  it "listing members" do
    visit "/members"
    puts page.html
  end
```

Awesome, this outputs the HTML from our members `index` page, just as
expected.

Let's make sure that the links are all there. We'll just test for the
link texts for now:

```ruby
describe App do
  let(:links) { within('ul') { page.all('a').map(&:text) } }

  it "listing members" do
    visit "/members"
    expect(links).to eq ['Anja', 'Edit', 'Remove', 'Maren', 'Edit', 'Remove']
  end
```

Ok, how do we look up those links there?

`within` expects a CSS selector. In our case we select the `ul` tag. Inside
that tag we then look for all `a` tags, and return the text (content) of each
tag. I.e. we end up with an array that has the texts of all links in our `ul`
tag.

That seems like a good way to make sure all the links are there. We'll want
to check their `href` attribute, too, but we can leave that for the following
tests that will click these links.

Hmmm, isn't that a little brittle though? What if we decide to change our
HTML at some point, and not use a `ul` tag any more. Maybe we'd use a `table`
or some other tag. Our app would still function the same, but our tests would
now fail.

Unfortunately our HTML does not give a lot of clues what's what. There's no
way to identify the list of members, other than looking for the `ul` tag.

One good way of dealing with this is to use a HTML `id`. In HTML an `id` is a
unique identifier on a page, and it can be used to ... well, identify that
element.

So, let's change our `index.erb` view to add that `id`:

```erb
<ul id="members">
  ...
</ul>
```

That seems good. An `ul` is a list, and we call it `members`. Pretty
straightforward.

Now we can change our tests to look for the element with the `members` id.
Since we're using a CSS selector here, `#members` selects our list.

```ruby
  let(:links) { within('#members') { page.all('a').map(&:text) } }
```

That's better.

Let's implement the next story.

```ruby
  it "showing member details" do
    # go to the members list
    visit "/members"

    # click on the link
    click_on "Maren"

    # check the h1 tag
    expect(page).to have_css 'h1', text: 'Member: Maren'

    # check the name
    expect(page).to have_content 'Name: Maren'
  end
```

See the pattern? We go to the members list, click the respective link, and then
we can assert that the page shows the contents we care about.

We're using the `have_css` and `have_content` matchers here. Again, `have_css`
expects a CSS selector, and `h1` simply selects the element with this tag name.
We then also specify the content that we expect on this `h1` tag. There's no
matcher for expecting various elements on the page at once, which is why we
had to find and check the links on the members list manually in our first test.

Ok, let's try the next story:

```ruby
  it "creating a new member" do
    # go to the members list
    visit "/members"

    # click on the link
    click_on "New Member"

    # fill in the form
    fill_in "name", :with => "Monsta"

    # submit the form
    find('input[type=submit]').click

    # check the current path
    expect(page).to have_current_path "/members/Monsta"

    # check the message
    expect(page).to have_content 'Successfully saved the new member: Monsta.'

    # check the h1 tag
    expect(page).to have_css 'h1', text: 'Member: Monsta'
  end
```

Woha. This actually works, our test passes.

You see that, after navigating to the "new member" page, filling in the form,
and submitting it, we can assert that we're now looking at the right path, and
there's a confirmation message, and the right `h1` tag on the page.

However, if you look closely, when we select the input tag to fill in, we need
to use the actual name attribute of that input tag (which happens to be `name`
in our case).

We said we wanted to forumate tests in a way that they reflect what our users
see, and care about, right? They don't see the name attribute of an input tag
at all.

Our test tells us something about our HTML here: There's no way for the user
to know what the input field is for.

Also, in the next line, we select the submit button with `find('input[type=submit]')`.
This, again, is a CSS selector that selects an input tag that has the attribute
`type` set to `submit`.

That's the same problem, isn't it? The user does not see the `type` attribute,
and they don't care about it.

Let's fix that.

In HTML the right way to name an input field is adding a `label` tag. A label
tag has a `for` attribute that identifies the input field it is, well, for.
This way software, i.e. browsers, screenreaders, but also our tests, can
identify the field.

Adding labels to form elements generally is a good idea in web development.
So let's add a label to our `new.erb`, and `edit.erb` views:

```erb
  <label for="name">Name</label>
  <input type="text" id="name" name="name" value="<%= @member.name %>">
```

You can see how the `for` attribute of the `label` tag relates to the `id`
attribute of the `input` tag. Here is the specification for `for` on
[MDN](https://developer.mozilla.org/en/docs/Web/HTML/Element/label#attr-for)
(a great resource about all things HTML).

While we're at it, let's also add a `value` attribute to the `submit` input tag
in both forms. This tells the browser to display a certain value to the user.

```erb
  <input type="submit" value="Save">
```

Great.

Now we can change our tests to use the actual texts that the user sees on the
page:

```ruby
    # fill in the form
    fill_in "Name", :with => "Monsta"

    # submit the form
    click_on "Save"
```

Awesome.

Our tests now really read like a story about our user's experience, except,
maybe when we assert the current path. This one is debateable:

On one hand users can see that path in the URL in their browser. On the other
hand most users usually don't really care about it, and often don't look at it.

We'll just keep this assertion because it helps us express in our tests which
page we expect to be on.

How about you go ahead and try to fill in the two remaining user stories. That
seems like a great exercise at this point.

Doing so you'll want to select a specific "Edit" link, and then later a "Remove"
link.

The Capybara [documentation](http://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Actions#click_link_or_button-instance_method)
does not mention this for some reason, but there's an option `match: :first`
that you can pass to the `click_on` method (e.g. `click_on "Edit", match:
:first`). This will click the first matching link.

Have fun!

## Footnotes

[1] In the short history of software development the semantics of testing, and
terms for various kinds of tests, have changed a lot. If you ask 10 different
developers to define the most important kinds of tests you'll probably get 10
different lists of definitions.
