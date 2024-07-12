class Participant < ApplicationRecord
  belongs_to :trip

  validates :email, presence: true
end
