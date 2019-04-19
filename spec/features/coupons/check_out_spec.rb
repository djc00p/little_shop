require "rails_helper"

RSpec.describe "Cart Coupons" do
  before :each do
    @user = create(:user)
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @coupon_1 = create(:coupon, user: @merchant_1)
    @coupon_2 = create(:coupon, user: @merchant_1)
    @coupon_3 = create(:coupon, user: @merchant_2)
    @coupon_4 = create(:coupon, user: @merchant_2)
    @i1, @i2, @i3 = create_list(:item, 3, user: @merchant_1)
    @i4, @i5, @i6 = create_list(:item, 3, user: @merchant_2)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    visit item_path(@i1)
    click_on "Add to Cart"
    visit item_path(@i2)
    click_on "Add to Cart"
    visit item_path(@i3)
    click_on "Add to Cart"
    visit item_path(@i4)
    click_on "Add to Cart"
    visit item_path(@i5)
    click_on "Add to Cart"
    visit item_path(@i6)
    click_on "Add to Cart"
    visit cart_path
  end

  it "should have a field for coupon code" do
    expected = @i1.price + @i2.price + @i3.price + @i4.price + @i5.price + @i6.price
    fill_in "Coupon", with: 'Coupon 1'
    #
    click_button "Apply Coupon"
    expect(page).to have_content("Total: $#{expected}")
    expect(page).to have_content("Discount Total: $#{expected - @coupon_1.dollars_off}")
  end

  it "total discount price" do
    expected = @i1.price + @i2.price + @i3.price + @i4.price + @i5.price + @i6.price
    fill_in "Coupon", with: 'Coupon 1'

    click_button "Apply Coupon"

    click_on "Check Out"
    last_order =  Order.last

    click_on "#{last_order.id}"

    expect(page).to have_content("Total Cost: $#{expected - @coupon_1.dollars_off}")

  end

  it "should only apply to items that belong to the merchant of that coupon" do
    expected = @i1.price + @i2.price + @i3.price + @i4.price + @i5.price + @i6.price

    fill_in "Coupon", with: 'Coupon 1'

    click_button "Apply Coupon"

    click_on "Check Out"
    last_order =  Order.last

    order_item = OrderItem.find_by(order_id: last_order.id, item_id: @i1.id)

    click_on "#{last_order.id}"

    within "#oitem-#{order_item.id}" do
      expect(page).to have_content("Price: $0.00")
    end
  end

  it "should not be able to apply same coupon and see flash message" do
    @o1 = create(:order, coupon_id: @coupon)

    fill_in "Coupon", with: 'Coupon 1'

    click_button "Apply Coupon"

    click_on "Check Out"

    expect(page).to have_content("Coupon not saved")
  end
end
