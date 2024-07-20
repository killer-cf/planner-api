class Participant < ApplicationRecord
  belongs_to :trip
  belongs_to :user, optional: true

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :trip_id }

  before_create :set_user

  private

  def set_user
    self.user = User.find_by(email: email)
  end
end
