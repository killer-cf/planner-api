class ActivityPolicy < ApplicationPolicy
  def destroy?
    puts record.trip.users
    user.present? && record.trip.users.include?(user)
  end
end
