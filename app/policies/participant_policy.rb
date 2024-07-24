class ParticipantPolicy < ApplicationPolicy
  def update?
    this_participant? || trip_owner?
  end

  def destroy?
    this_participant? || trip_owner?
  end

  def confirm?
    true
  end

  private

  def this_participant?
    user.present? && record.user == user
  end

  def trip_owner?
    user.present? && record.trip.owner == user
  end
end
