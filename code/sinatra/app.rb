require "sinatra/base"
require "member"
require "member_validator"

class App < Sinatra::Base
  FILENAME = "members.txt"

  use Rack::MethodOverride

  enable :sessions

  before do
    @message = session.delete(:message)
  end

  get "/members" do
    @members = members
    erb :index
  end

  get "/members/new" do
    @member = Member.new
    erb :new
  end

  post "/members" do
    @member = Member.new(params[:name])
    validator = MemberValidator.new(@member, members)

    if validator.valid?
      add_member(@member.name)
      session[:message] = "Successfully saved the new member: #{@member.name}."
      redirect "/members/#{@member.id}"
    else
      @messages = validator.messages
      erb :new
    end
  end

  get "/members/:id" do
    @member = find_member(params[:id])
    erb :show
  end

  get "/members/:id/edit" do
    @member = find_member(params[:id])
    erb :edit
  end

  put "/members/:id" do
    @member = find_member(params[:id])
    @member.name = params[:name]
    validator = MemberValidator.new(@member, members)

    if validator.valid?
      update_member(params[:id], @member.name)
      session[:message] = "Successfully updated the member: #{@member.name}."
      redirect "/members/#{@member.id}"
    else
      @messages = validator.messages
      erb :new
    end
  end

  get "/members/:id/delete" do
    @member = find_member(params[:id])
    erb :delete
  end

  delete "/members/:id" do
    member = remove_member(params[:id])
    session[:message] = "Successfully removed the member: #{params[:id]}."
    redirect "/members"
  end

  def names
    return [] unless File.exists?(FILENAME)
    File.read(FILENAME).split("\n")
  end

  def members
    names.map { |name| Member.new(name) }
  end

  def find_member(id)
    members.detect { |member| member.id == id }
  end

  def add_member(name)
    File.write(FILENAME, name, mode: File::WRONLY | File::APPEND | File::CREAT)
  end

  def update_member(id, name)
    lines = names.dup
    lines[lines.index(id)] = name
    store(lines)
  end

  def store(lines)
    File.write(FILENAME, lines.join("\n"), mode: File::WRONLY | File::TRUNC | File::CREAT)
  end

  def remove_member(name)
    lines = names.reject { |other| name == other }
    store(lines)
  end
end
