class Member
  attr_accessor :name

  def initialize(name = nil)
    @name = name.to_s
  end

  def id
    name
  end
end
