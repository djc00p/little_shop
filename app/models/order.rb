class Order < ApplicationRecord
  belongs_to :user
  # belongs_to :coupon
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status

  enum status: [:pending, :packaged, :shipped, :cancelled]

  def total_item_count
    order_items.sum(:quantity)
  end

  def total_cost
    oi = order_items.pluck("sum(quantity * price)")
    oi.sum
  end

  def self.pending_orders_for_merchant(merchant_id)
    self.joins(:items)
        .where(status: :pending)
        .where(items: {merchant_id: merchant_id})
        .distinct
  end

  def total_quantity_for_merchant(merchant_id)
    items.joins(:order_items)
         .select('items.id, order_items.quantity')
         .where(items: {merchant_id: merchant_id})
         .distinct
         .sum('order_items.quantity')
  end

  def total_price_for_merchant(merchant_id)
    items.joins(:order_items)
         .where(items: {merchant_id: merchant_id})
         .select('items.id, order_items.quantity, order_items.price')
         .distinct
         .sum('order_items.quantity * order_items.price')
  end

  def order_items_for_merchant(merchant_id)
    order_items.joins(:item)
               .where(items: {merchant_id: merchant_id})
  end

  def self.orders_by_status(status)
    Order.where(status: status)
  end

  def self.pending_orders
    orders_by_status(:pending)
  end

  def self.packaged_orders
    orders_by_status(:packaged)
  end

  def self.shipped_orders
    orders_by_status(:shipped)
  end

  def self.cancelled_orders
    orders_by_status(:cancelled)
  end

  def self.sorted_by_items_shipped(limit = nil)
    self.joins(:order_items)
        .select('orders.*, sum(order_items.quantity) as quantity')
        .where(status: :shipped, order_items: {fulfilled: true})
        .group(:id)
        .order('quantity desc')
        .limit(limit)
  end

  def self.missing_revenue(merchant_id)
    total_revenue = pending_orders.map  do |order|
      order.total_price_for_merchant(merchant_id)
    end
    total_revenue.sum
    # .joins(:order_items).where(status: :pending).pluck(:price).sum
  end

  def inventory_check
    items.pluck(:inventory)
  end

  def quantity_check
    order_items.pluck(:quantity)
  end

  def quantity_less_than_inventory?(order)
    a = order.inventory_check
    b = order.quantity_check
    a.zip(b).all? { |a, b| a > b }
  end
end
