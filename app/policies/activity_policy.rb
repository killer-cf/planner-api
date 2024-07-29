class ActivityPolicy < ApplicationPolicy
  def create?
    trip_participant?
  end

  def update?
    trip_participant?
  end

  def destroy?
    trip_participant?
  end

  private

  def trip_participant?
    user.present? && record.trip.users.include?(user)
  end
end
