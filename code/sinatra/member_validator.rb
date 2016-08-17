class MemberValidator
  attr_reader :member, :members, :messages

  def initialize(member, members)
    @member = member
    @members = members
    @messages = []
  end

  def valid?
    validate
    messages.empty?
  end

  private

    def names
      members.map { |member| member.name }
    end

    def validate
      if member.name.empty?
        messages << "You need to enter a name"
      elsif names.include?(member.name)
        messages << "#{member.name} is already included in our list."
      end
    end
end
