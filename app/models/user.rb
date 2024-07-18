class User < ApplicationRecord
  validates :name, :email, :external_id, presence: true
end
