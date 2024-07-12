class Link < ApplicationRecord
  belongs_to :trip

  validates :title, :url, presence: true
end
