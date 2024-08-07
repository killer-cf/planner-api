class Trip < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :guests, -> { where(is_owner: false) }, class_name: 'Participant', dependent: :destroy, inverse_of: :trip
  has_many :activities, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :users, through: :participants
  has_one :owner_participant, lambda {
                                where(is_owner: true)
                              }, class_name: 'Participant', dependent: :destroy, inverse_of: :trip
  has_one :owner, through: :owner_participant, source: :user

  validates :destination, :starts_at, :ends_at, presence: true
  validates :destination, length: { minimum: 4 }
  validate :starts_at_is_valid_date
  validate :ends_at_is_valid_date
  validate :ends_at_is_after_starts_at

  after_update :delete_activities_outside_range

  def send_confirmation_emails
    guests.each do |participant|
      TripMailer.with(email: participant.email, trip: self, participant_id: participant.id).confirm_trip.deliver_later
    end
  end

  private

  def starts_at_is_valid_date
    return if valid_date?(starts_at)

    errors.add(:starts_at, 'must be a valid date')
  end

  def ends_at_is_valid_date
    return if valid_date?(ends_at)

    errors.add(:ends_at, 'must be a valid date')
  end

  def ends_at_is_after_starts_at
    return unless starts_at.present? && ends_at.present? && ends_at <= starts_at

    errors.add(:ends_at, 'must be after the start date')
  end

  def valid_date?(date)
    date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time)
  end

  def delete_activities_outside_range
    start_of_day = starts_at.beginning_of_day
    end_of_day = ends_at.end_of_day
    activities.where('occurs_at < ? OR occurs_at > ?', start_of_day, end_of_day).destroy_all
  end
end
