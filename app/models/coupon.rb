class Coupon < ApplicationRecord
belongs_to :user, foreign_key: 'merchant_id'
has_many :orders
validates :name, uniqueness: true, presence: true
validates_presence_of :dollars_off


  def in_use?
    binding.pry
    coupons.count > 0
  end
end
