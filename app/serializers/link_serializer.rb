class LinkSerializer < ApplicationSerializer
  attributes :id, :title, :url
  has_one :trip
end
