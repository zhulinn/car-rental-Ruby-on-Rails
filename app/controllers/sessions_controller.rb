class SessionsController < ApplicationController

  def new
    if logged_in?
      if current_authority == $superadmin
        redirect_to super_admin_url(current_user)
      elsif current_authority == $admin
        redirect_to admin_url(current_user)
      else
        redirect_to customer_url(current_user)
      end
    end
  end

  def create
    user = SuperAdmin.find_by(email: params[:session][:email].downcase)
    user = Admin.find_by(email: params[:session][:email].downcase) if user==nil
    user = Customer.find_by(email: params[:session][:email].downcase) if user==nil
    authority=user.class.to_s unless user==nil
    if user && user.authenticate(params[:session][:password])
      # 登入用户，然后重定向到用户的资料页面
      flash[:notice] = ''

      log_in user, authority
      redirect_to user
    else
      flash[:notice] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end