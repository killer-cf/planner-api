require 'rails_helper'

RSpec.describe Link, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_length_of(:title).is_at_least(4) }
end
