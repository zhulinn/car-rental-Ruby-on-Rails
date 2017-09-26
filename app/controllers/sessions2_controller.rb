class Sessions2Controller < ApplicationController

  def new
  end

  def create
    user = Admin.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # 登入用户，然后重定向到用户的资料页面
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      
    end
  end

  def destroy
    log_out
    redirect_to "http://localhost:3000/"

  end
end