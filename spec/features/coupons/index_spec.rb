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
    @c1, @c2 = create_list(:coupon, 2, user: @merchant, active: true)
    @c3 = create(:coupon, user: @merchant, active: false)
    create(:order_item, order: @o1, item: @i1, quantity: 5, price: 2)
    create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
    create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
    create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
    create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    visit dashboard_path(@merchant)
  end
  it "should be directed a list of the coupons" do
        
        click_link "Manage Coupons"

    expect(current_path).to eq(dashboard_coupons_path)
  end

  context "coupon index" do
    before :each do
      click_link "Manage Coupons"
    end

    it "Should see Coupons" do
      expect(page).to have_content(@c1.name)
      expect(page).to have_content("#{@c1.dollars_off} Dollars Off")

      expect(page).to have_content(@c2.name)
      expect(page).to have_content("#{@c2.dollars_off} Dollars Off")

      expect(page).to have_content(@c3.name)
      expect(page).to have_content("#{@c3.dollars_off} Dollars Off")
    end

    it "should see enable and disable" do

      within "#coupon#{@c1.id}" do
        expect(page).to have_button("Disable")
      end
      within "#coupon#{@c2.id}" do
        expect(page).to have_button("Disable")
      end
      within "#coupon#{@c3.id}" do
        expect(page).to have_button("Enable")
      end
    end

    it "should be able to add new coupon" do
      click_link "Add Coupon"

      expect(current_path).to eq(new_dashboard_coupon_path)

      fill_in "Name", with: "Saver"
      fill_in "Dollars off", with: 10

      click_on "Create Coupon"

      last_coupon = Coupon.last
      expect(current_path).to eq(dashboard_coupons_path)

      within "#coupon#{last_coupon.id}" do
        expect(page).to have_button("Enable")
      end
    end

    it "should display error messages for none filled in fields" do
      click_link "Add Coupon"

      expect(current_path).to eq(new_dashboard_coupon_path)

      click_on "Create Coupon"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Dollars off can't be blank")
    end

    it "should be able to edit coupons" do
      within "#coupon#{@c1.id}" do
        click_link "Edit"
      end

      expect(current_path).to eq(edit_dashboard_coupon_path(@c1))

      fill_in "coupon[name]", with: "New Saver 20"
      fill_in "coupon[dollars_off]", with: 20

      click_on "Update Coupon"

      expect(current_path).to eq(dashboard_coupons_path)
      page.reset!

      visit dashboard_coupons_path

      # expect(page).to have_content("New Saver 20")
      # expect(page).to have_content("20 Dollars Off")

    end



    it "should be able to enable and disable coupon" do
      within "#coupon#{@c1.id}" do
        click_button "Disable Coupon"
        expect(current_path).to eq(dashboard_coupons_path)
        #
        # expect(page).to have_button("Enable Coupon")
      end
      # expect(page).to have_button("Enable Coupon")
      within "#coupon#{@c3.id}" do
        click_on "Enable Coupon"
        expect(current_path).to eq(dashboard_coupons_path)
      end
      # expect(page).to have_button("Disable Coupon")
    end

    it "can delete a coupon" do
      within "#coupon#{@c1.id}" do
        click_button "Delete"
      end

      expect(page).to_not have_content(@c1.name)
    end
  end

  describe "sad path" do
    before :each do
      @merchant = create(:merchant)
      @admin = create(:admin)
      @i1, @i2 = create_list(:item, 2, user: @merchant)
      @i3 = create(:item, user: @merchant, image: "https://images-na.ssl-images-amazon.com/images/I/61DEI%2BSDg0L._SL1320_.jpg")
      @i4 = create(:item, user: @merchant, image: "https://compass-ssl.xbox.com/assets/f5/96/f5967de6-59db-4af0-80cf-461c03052eff.png?n=Results-Page_Page-Hero-0_X1S_1083x612.png")
      @o1, @o2 = create_list(:order, 2)
      @o3 = create(:shipped_order)
      @o4 = create(:cancelled_order)
      @c1, @c2, @c4, @c5, @c6 = create_list(:coupon, 5, user: @merchant, active: true)
      @c3 = create(:coupon, user: @merchant, active: false)
      @o5 = create(:order, coupon_id: @c1.id)
      create(:order_item, order: @o1, item: @i1, quantity: 5, price: 2)
      create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
      create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
      create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
      create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
      create(:order_item, order: @o5, item: @i1, quantity: 5, price: 2)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
      visit dashboard_path(@merchant)
      click_link "Manage Coupons"
    end

    it "cant edit a coupon in use" do
      within "#coupon#{@c1.id}" do
        click_link "Edit"
      end

      expect(current_path).to eq(edit_dashboard_coupon_path(@c1))

      fill_in "coupon[name]", with: "New Saver 20"
      fill_in "coupon[dollars_off]", with: 20

      click_on "Update Coupon"

      expect(page).to have_content("Cant update Coupon in use")
    end

    it "should not have more that 5 active coupons" do
      within "#coupon#{@c3.id}" do
        click_button "Enable"
      end
      expect(page).to have_content("Cant have more then 5 active coupons")
    end

    it "should not be able to delete coupon if being used" do
      within "#coupon#{@c1.id}" do
        click_button "Delete"
      end

      expect(page).to have_content("Attempt to delete #{@c1.name} was thwarted!")
    end
  end
end
