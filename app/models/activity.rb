class Activity < ApplicationRecord
  belongs_to :trip

  validates :title, :occurs_at, presence: true
  validates :title, length: { minimum: 4 }
  validate :occurs_at_is_valid_date

  private

  def occurs_at_is_valid_date
    return if valid_date?(occurs_at)

    errors.add(:occurs_at, 'must be a valid date')
  end

  def valid_date?(date)
    date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time)
  end
end
