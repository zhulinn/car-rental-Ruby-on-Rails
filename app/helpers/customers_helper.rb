module CustomersHelper
  def pin_customer customer
    session[:customer_id] = customer.id
  end

  def current_customer
    @current_customer ||= Customer.find(session[:customer_id])
  end

  def delete_customer_pin
    session.delete(:customer_id)
    @current_customer = nil
  end
end
