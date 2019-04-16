require 'rails_helper'

RSpec.describe "Coupon List" do
  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)
    @i1, @i2 = create_list(:item, 2, user: @merchant)
    @i3 = create(:item, user: @merchant, image: "https://images-na.ssl-images-amazon.com/images/I/61DEI%2BSDg0L._SL1320_.jpg")
    @i4 = create(:item, user: @merchant, image: "https://compass-ssl.xbox.com/assets/f5/96/f5967de6-59db-4af0-80cf-461c03052eff.png?n=Results-Page_Page-Hero-0_X1S_1083x612.png")
    @o1, @o2 = create_list(:order, 2)
    @o3 = create(:shipped_order)
    @o4 = create(:cancelled_order)
    create(:order_item, order: @o1, item: @i1, quantity: 5, price: 2)
    create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
    create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
    create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
    create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    visit dashboard_path(@merchant)
  end
  it "should be directed a list of the coupons" do
    # save_and_open_page
    # binding.pry
    click_link "Manage Coupons"

    expect(current_path).to eq(dashboard_coupons_path)
  end
end
