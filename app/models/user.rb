class User < ApplicationRecord
  has_many :participants, dependent: :nullify
  has_many :trips, through: :participants

  validates :name, :email, :external_id, presence: true
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :email, uniqueness: { case_sensitive: false }

  before_save :email_to_downcase

  def add_participants_by_emails(emails)
    emails = emails.compact.uniq

    participants_to_add = Participant.where(email: emails)

    participants_to_add.each do |participant|
      participants << participant if participants.exclude?(participant)
    end
  end

  def email_to_downcase
    return unless email

    self.email = email.downcase
  end
end
