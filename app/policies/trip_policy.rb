class TripPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def index?
    true
  end

  def show?
    user.present? && record.users.include?(user)
  end

  def update?
    user.present? && record.owner == user
  end

  def destroy?
    user.present? && record.owner == user
  end

  def activities?
    user.present? && record.users.include?(user)
  end

  def participants?
    user.present? && record.users.include?(user)
  end

  def links?
    user.present? && record.users.include?(user)
  end
end
