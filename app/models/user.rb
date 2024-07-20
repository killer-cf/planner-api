class User < ApplicationRecord
  has_many :participants, dependent: :nullify

  validates :name, :email, :external_id, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true

  def add_participants_by_emails(emails)
    emails = emails.compact.uniq

    participants_to_add = Participant.where(email: emails)

    participants_to_add.each do |participant|
      participants << participant if participants.exclude?(participant)
    end
  end
end
