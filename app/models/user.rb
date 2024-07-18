class User < ApplicationRecord
  has_many :participants, dependent: :nullify

  validates :name, :email, :external_id, presence: true
end
