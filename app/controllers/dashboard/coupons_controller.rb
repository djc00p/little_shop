class Dashboard::CouponsController < Dashboard::BaseController
  before_action :require_merchant

  def index
    @coupons = current_user.coupons
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = current_user.coupons.new(coupon_params)
    if @coupon.save
      flash[:success] = "Your Coupon has been saved!"
      redirect_to dashboard_coupons_path
    else
      flash[:danger] = @coupon.errors.full_messages
      render :new
    end
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end

  def update
    @coupon = Coupon.find(params[:id])
    if @coupon.orders.count > 0
      flash[:failure] = "Cant update Coupon in use"
      redirect_to dashboard_coupon_path(@coupon)
    else
      @coupon.update(coupon_params)
      if @coupon.save
        flash[:success] = "Your Coupon has been updated!"
        redirect_to dashboard_coupon_path(@coupon)
      else
        flash[:danger] = @coupon.errors.full_messages
        @coupon = Coupon.find(params[:id])
        render :edit
      end
    end
  end

  def enable
    @coupon = Coupon.find(params[:id])
    if current_user.coupons.active_count == 5
      toggle_active(@coupon, false)
      flash[:failure] = "Cant have more then 5 active coupons"
      redirect_to dashboard_coupons_path
    elsif @coupon.user == current_user
      toggle_active(@coupon, true)
      redirect_to dashboard_coupons_path
    else
      render file: 'public/404', status: 404
    end
  end

  def disable
    @coupon = Coupon.find(params[:id])
    if @coupon.user == current_user
      toggle_active(@coupon, false)
      redirect_to dashboard_coupons_path
    else
      render file: 'public/404', status: 404
    end
  end

  def destroy
    @coupon = Coupon.find(params[:id])
    if @coupon && @coupon.user == current_user
      if @coupon && @coupon.used_in_order?
        flash[:error] = "Attempt to delete #{@coupon.name} was thwarted! Currently in Use."
      else
        @coupon.destroy
      end
      redirect_to dashboard_items_path
    else
      render file: 'public/404', status: 404
    end
  end

  private
  def coupon_params
    params.require(:coupon).permit(:name, :dollars_off)
  end

  def toggle_active(coupon, state)
    coupon.active = state
    coupon.save
  end
end
