class Activity < ApplicationRecord
  belongs_to :trip

  validates :title, :occurs_at, presence: true
  validates :title, length: { minimum: 4 }
  validate :occurs_at_is_valid_date
  validate :occurs_at_within_trip_range

  private

  def occurs_at_is_valid_date
    return if valid_date?(occurs_at)

    errors.add(:occurs_at, 'must be a valid date')
  end

  def valid_date?(date)
    date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time)
  end

  def occurs_at_within_trip_range
    return if trip.blank? || occurs_at.blank?

    trip_start = trip.starts_at.beginning_of_day
    trip_end = trip.ends_at.end_of_day

    return unless occurs_at < trip_start || occurs_at > trip_end

    errors.add(:occurs_at, 'must be within the trip start and end dates')
  end
end
