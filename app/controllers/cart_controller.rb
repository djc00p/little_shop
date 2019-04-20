
class CartController < ApplicationController
  before_action :visitor_or_user

  def show
    if session[:coupon]
      @coupon = Coupon.find(session[:coupon])
    end
  end

  def increment
    item = Item.find(params[:id])
    if item.inventory <= cart.count_of(item.id)
      flash[:danger] = "The Merchant does not have enough inventory."
    else
      cart.add_item(item.id)
      session[:cart] = cart.contents
      flash[:success] = "#{item.name} has been added to your cart!"
    end
    redirect_to cart_path
  end

  def decrement
    item = Item.find(params[:id])
    cart.remove_item(item.id)
    session[:cart] = cart.contents
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end

  def destroy
    session.delete(:cart)
    session.delete(:coupon)
    redirect_to cart_path
  end

  def remove_item
    item = Item.find(params[:id])
    session[:cart].delete(item.id.to_s)
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end

  def coupon_check
    @coupon = Coupon.find_by(name: params[:coupon])
    if @coupon && current_user.orders.where(coupon_id: @coupon).count == 0
      session[:coupon] = @coupon.id
      flash[:notice] = "Coupon Applied"
    else
      flash[:danger] = "Coupon not saved"
    end
    redirect_to cart_path
  end
end
