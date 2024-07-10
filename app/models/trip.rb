class Trip < ApplicationRecord
  validates :destination, :starts_at, :ends_at, presence: true
  validates :destination, length: { minimum: 4 }
  validate :starts_at_is_valid_date
  validate :ends_at_is_valid_date
  validate :ends_at_is_after_starts_at

  private

  def starts_at_is_valid_date
    unless valid_date?(starts_at)
      errors.add(:starts_at, 'must be a valid date')
    end
  end

  def ends_at_is_valid_date
    unless valid_date?(ends_at)
      errors.add(:ends_at, 'must be a valid date')
    end
  end

  def ends_at_is_after_starts_at
    if starts_at.present? && ends_at.present? && ends_at <= starts_at
      errors.add(:ends_at, 'must be after the start date')
    end
  end

  def valid_date?(date)
    date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time)
  end
end
