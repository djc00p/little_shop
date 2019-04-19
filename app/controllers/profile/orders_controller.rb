class Profile::OrdersController < ApplicationController
  before_action :require_reguser

  def index
    @user = current_user
    @orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.user == current_user
      @order.order_items.where(fulfilled: true).each do |oi|
        item = Item.find(oi.item_id)
        item.inventory += oi.quantity
        item.save
        oi.fulfilled = false
        oi.save
      end

      @order.status = :cancelled
      @order.save

      redirect_to profile_orders_path
    else
      render file: 'public/404', status: 404
    end
  end

  def create
    order = Order.create(user: current_user, status: :pending)
    @coupon = Coupon.find(session[:coupon]) if session[:coupon]
    discount_left = @coupon.dollars_off if @coupon
      cart.items.each do |item, quantity|
        if @coupon && @coupon.merchant_id == item.merchant_id && discount_left > 0 && current_user.orders.where(coupon_id: @coupon).count == 0
          if quantity * item.price >= discount_left
            discounted_item_price = item.price - (discount_left.to_f / quantity)
            discount_left = 0
            order.order_items.create(item: item, quantity: quantity, price: discounted_item_price)
          else
            discount_left -= quantity * item.price
            order.order_items.create(item: item, quantity: quantity, price: 0)
          end
        else
          flash[:danger] = "Coupon not saved"
          order.order_items.create(item: item, quantity: quantity, price: item.price)
        end
      end
      session.delete(:cart)
      flash[:success] = "Your order has been created!"
      redirect_to profile_orders_path
  end
end
