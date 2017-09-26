class Sessions3Controller < ApplicationController

  def new
  end

  def create
    user = Super_admins.find_by(email: params[:session3][:email].downcase)
    if user && user.authenticate(params[:session3][:password])
      # 登入用户，然后重定向到用户的资料页面
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to "/index"

  end
end