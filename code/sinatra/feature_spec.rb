require "app"
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.app = proc { |env| App.new.call(env) }

RSpec.configure do |config|
  config.include Capybara::DSL
  config.before { File.write("members.txt", "Anja\nMaren\n") }
end

describe App do
  let(:links) { within('#members') { page.all('a').map(&:text) } }

  it "listing members" do
    # go to the members list
    visit "/members"

    # check the list of links
    expect(links).to eq ['Anja', 'Edit', 'Remove', 'Maren', 'Edit', 'Remove']
  end

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

  it "creating a new member" do
    # go to the members list
    visit "/members"

    # click on the link
    click_on "New Member"

    # fill in the form
    fill_in "Name", :with => "Monsta"

    # submit the form
    click_on "Save"

    # check the current path
    expect(page).to have_current_path "/members/Monsta"

    # check the message
    expect(page).to have_content 'Successfully saved the new member: Monsta.'

    # check the h1 tag
    expect(page).to have_css 'h1', text: 'Member: Monsta'
  end

  it "updating a member" do
    # go to the members list
    visit "/members"

    # click on the link for Anja
    click_on "Edit", match: :first

    # fill in the form
    fill_in "Name", :with => "Tyranja"

    # submit the form
    click_on "Save"

    # check the current path
    expect(page).to have_current_path "/members/Tyranja"

    # check the message
    expect(page).to have_content 'Successfully updated the member: Tyranja.'

    # check the h1 tag
    expect(page).to have_css 'h1', text: 'Member: Tyranja'
  end

  it "removing a member" do
    # go to the members list
    visit "/members"

    # click on the link for Anja
    click_on "Remove", match: :first

    # check the message
    expect(page).to have_content /Are you sure .*?/

    # click the button
    click_on "Yes"

    # check the current path
    expect(page).to have_current_path "/members"

    # check the message
    expect(page).to have_content 'Successfully removed the member: Anja.'

    # check the list
    expect(page).to have_selector('li', count: 1)
  end
end
