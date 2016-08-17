require "spec_helper"

describe App do
  let(:app) { App.new }

  context "GET to /members" do
    let(:response) { get "/members" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays a list of member names that link to /members/:name" do
      expect(response.body).to have_tag(:a, :href => "/members/Anja", :text => "Anja")
      expect(response.body).to have_tag(:a, :href => "/members/Maren", :text => "Maren")
    end
  end

  context "GET to /members/:name" do
    let(:response) { get "/members/Anja" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays the member's name" do
      expect(response.body).to have_tag(:p, :text => "Name: Anja")
    end
  end

  context "GET to /members/new" do
    let(:response) { get "/members/new" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end

    it "displays a form that POSTs to /members" do
      expect(response.body).to have_tag(:form, :action => "/members", :method => "post")
    end

    it "displays an input tag for the name" do
      expect(response.body).to have_tag(:input, :type => "text", :name => "name")
    end

    it "displays a submit tag" do
      expect(response.body).to have_tag(:input, :type => "submit")
    end
  end

  context "POST to /members" do
    let(:file) { File.read("members.txt") }
    before     { File.write("members.txt", "Anja\nMaren") }

    context "given a valid name" do
      let!(:response) { post "/members", :name => "Monsta" }

      it "adds the name to the members.txt file" do
        expect(file).to include("Monsta")
      end

      it "returns status 302 Found" do
        expect(response.status).to eq 302
      end

      it "redirects to /members/:name" do
        expect(response).to redirect_to "/members/Monsta"
      end
    end

    shared_examples_for "invalid member data" do
      let!(:response) { post "/members", :name => "Maren" }

      it "does not add the name to the members.txt file" do
        expect(file).to eq "Anja\nMaren"
      end

      it "returns status 200 OK" do
        expect(response.status).to eq 200
      end

      it "displays a form that POSTs to /members" do
        expect(response.body).to have_tag(:form, :action => "/members", :method => "post")
      end

      it "displays an input tag for the name, with the value set" do
        expect(response.body).to have_tag(:input, :type => "text", :name => "name", :value => "Maren")
      end
    end

    context "given a duplicate name" do
      include_examples "invalid member data"
    end

    context "given an empty name" do
      include_examples "invalid member data"
    end
  end
end
