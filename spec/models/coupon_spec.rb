require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_uniqueness_of :name}
    it { should validate_presence_of :dollars_off }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :orders }
  end

  describe "instance methods" do
    before :each do
      user = create(:user)
      @item_1 = create(:item)
      @item_2 = create(:item)
      yesterday = 1.day.ago
      @coupon = create(:coupon)
      @order = create(:order, user: user, created_at: yesterday, coupon: @coupon)
      #
      @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 1, created_at: yesterday, updated_at: yesterday)
      @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 1, created_at: yesterday, updated_at: 2.hours.ago)

      @merchant = create(:merchant)
      @i1, @i2 = create_list(:item, 2, user: @merchant)
      @o1, @o2 = create_list(:order, 2)
      @o3 = create(:packaged_order)
      @o4 = create(:shipped_order)
      @o5 = create(:cancelled_order)
      create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
      create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
      create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
      create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
      create(:order_item, order: @o5, item: @i1, quantity: 5, price: 2)
    end

    it ".used_in_order?" do
      expect(@coupon.used_in_order?).to eq(true)
    end
  end
end
