class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  #include Sessions2Helper
  #include Sessions3Helper
  $customer="Customer"
  $admin="Admin"
  $superadmin="SuperAdmin"

  def back_if_not_logged_in
    unless logged_in?
      back_to_place
    end
  end

  def back_if_customer
    if logged_in? and current_authority=="Customer"
      back_to_place
    end
  end

  def back_if_not_self_customer
    if logged_in? and current_authority=="Customer" and current_user!=Customer.find(params[:id])
      back_to_place
    end
  end

  def back_to_place
    if !logged_in?
      redirect_to login_url
    elsif current_authority==$customer
      redirect_to customer_url(current_user)
    elsif current_authority==$admin
      redirect_to admin_url(current_user)
    else
      redirect_to super_admin_url(current_user)
    end
  end
end
