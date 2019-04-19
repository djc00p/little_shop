require 'rails_helper'

RSpec.describe "Coupon show page" do
  before :each do
    @merchant = create(:merchant)
    @coupon =  create(:coupon, user: @merchant)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
    visit dashboard_path(@merchant)
  end
  it "display coupon info" do
    visit dashboard_coupon_path(@coupon)

    expect(page).to have_content("#{@coupon.name}")
    expect(page).to have_content("#{@coupon.dollars_off}")
    expect(page).to have_link("Edit")
  end
end
