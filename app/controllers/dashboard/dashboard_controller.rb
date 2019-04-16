class Dashboard::DashboardController < Dashboard::BaseController
  def index
    @merchant = current_user
    @pending_orders = Order.pending_orders_for_merchant(current_user.id)
    @revenue = Order.missing_revenue(current_user.id)
    # @order_items = @pending_orders.order_items_for_merchant(@merchant.id)
  end
end
