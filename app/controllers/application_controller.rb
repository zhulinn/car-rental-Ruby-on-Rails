class ApplicationController < ActionController::Base
  config.time_zone = 'Eastern Time (US & Canada)'
  #config.active_record.default_timezone = :local
  protect_from_forgery with: :exception
  require 'rufus-scheduler'
  include SessionsHelper
  include CustomersHelper
  $customer = 'Customer'
  $admin = 'Admin'
  $superadmin = 'SuperAdmin'
  $available = 'Available'
  $reserved = 'Reserved'
  $checkedout = 'Checked Out'
  $returned = 'Returned'
  $cancelled = 'Cancelled'
  $suggested = 'Suggested'

  $scheduler = Rufus::Scheduler.new

  def back_if_not_logged_in
    back_to_place unless logged_in?
  end

  def back_if_customer
    back_to_place if logged_in? && current_authority == $customer
  end

  def back_if_admin
    back_to_place if logged_in? && current_authority == $admin
  end

  def back_if_not_self_customer
    back_to_place if
        logged_in? &&
        current_authority == $customer &&
        current_user != Customer.find(params[:id])
  end

  def back_if_not_self_admin
    back_to_place if
        logged_in? &&
        current_authority == $admin &&
        current_user != Admin.find(params[:id])
  end

  def back_if_not_self_supoer_admin
    back_to_place if
        logged_in? &&
        current_authority == $superadmin &&
        current_user != SuperAdmin.find(params[:id])
  end

  def back_to_place
    if !logged_in?
      redirect_to login_url
    elsif current_authority == $customer
      redirect_to customer_url(current_user)
    elsif current_authority == $admin
      redirect_to admin_url(current_user)
    else
      redirect_to super_admin_url(current_user)
    end
  end
end
