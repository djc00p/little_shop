class Coupon < ApplicationRecord
belongs_to :user, foreign_key: 'merchant_id'
has_many :orders
validates_uniqueness_of :name
validates_presence_of :dollars_off

  def self.active_count
    where(active: true).count
  end

  def used_in_order?
    orders.count > 0
  end
end
