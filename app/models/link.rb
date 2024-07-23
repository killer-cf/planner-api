class Link < ApplicationRecord
  belongs_to :trip

  validates :title, :url, presence: true
  validates :title, length: { minimum: 4 }
end
