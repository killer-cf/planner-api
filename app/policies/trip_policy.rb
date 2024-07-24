class TripPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def index?
    true
  end

  def show?
    participant?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def activities?
    participant?
  end

  def participants?
    participant?
  end

  def links?
    participant?
  end

  def invites?
    owner?
  end

  def confirm?
    true
  end

  private

  def owner?
    user.present? && record.owner == user
  end

  def participant?
    user.present? && record.users.include?(user)
  end
end
