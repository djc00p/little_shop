require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of :name}
    it { should validate_presence_of :dollars_off }
  end

  describe 'relationships' do
    it { should belong_to :user }
  end
end
