FactoryBot.define do
  factory :coupon do
    association :user, factory: :merchant
    sequence(:name) { |n| "Coupon #{n}" }
    sequence(:dollars_off) { |n| ("#{n}".to_i+5)*1.5 }
    active { true }
  end

  factory :inactive_coupon, parent: :item do
    association :user, factory: :merchant
    sequence(:name) { |n| "Inactive Coupon Name #{n}" }
    active { false }
  end
end
