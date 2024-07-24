class Participant < ApplicationRecord
  belongs_to :trip
  belongs_to :user, optional: true

  validates :email, presence: true
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :email, uniqueness: { scope: :trip_id }

  before_create :set_user

  private

  def set_user
    return if user.present?

    self.user = User.find_by(email: email)
  end
end
