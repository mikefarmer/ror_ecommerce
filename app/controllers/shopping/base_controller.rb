class Shopping::BaseController < ApplicationController
  helper_method :session_order, :session_order_id
  # these are methods that can be used for all orders

  protected

  def ssl_required?
    ssl_supported?
  end

  private

  def next_form(order)

       # if cart is empty
    if session_cart.cart_items.empty?
      flash[:notice] = 'You don\'t have anything in your cart'
      return root_url

       ## If we are insecure
    elsif not_secure?
      #Rails.logger.debug "NOT SECURE!!!"
      session[:return_to] = shopping_orders_url
      return login_url()
    elsif session_order.ship_address_id.nil?
      #Rails.logger.debug "SHIPPING ADDRESS INVALID"
      return shopping_addresses_url()
    elsif session_order.order_items.any?{ |item| item.shipping_rate_id.nil? }
      #Rails.logger.debug "NO SHIPPING METHOD SELECTED"
      return shopping_shipping_methods_url()
    end
  end

  def not_secure?
    !current_user ||
    session[:authenticated_at].nil? ||
    (Time.now - session[:authenticated_at] > (60 * 20) ) || ## 20 minutes
    (cookies[:insecure].nil? || cookies[:insecure] == true)## this should happen every time the user goes to a non-SSL page
  end

  def session_order
    find_or_create_order
  end

  def session_order_id
    session[:order_id] ? session[:order_id] : find_or_create_order.id
  end

  def find_or_create_order
    return @session_order if @session_order
    if session[:order_id]
      @session_order = current_user.orders.includes([ {:ship_address => :state},
                                                      {:bill_address => :state},
                                                      {:order_items =>
                                                        {:variant =>
                                                          {:product => :images }}}]).find(session[:order_id])
      create_order if !@session_order.in_progress?
    else
      create_order
    end
    @session_order
  end

  def create_order
    @session_order = current_user.orders.create(:number       => Time.now.to_i,
                                                :ip_address   => request.env['REMOTE_ADDR'],
                                                :bill_address => current_user.billing_address  )
    add_new_cart_items(session_cart.shopping_cart_items)
    session[:order_id] = @session_order.id
  end

  def add_new_cart_items(items)
    items.each do |item|
      @session_order.add_items(item.variant, item.quantity)
    end
  end
end
