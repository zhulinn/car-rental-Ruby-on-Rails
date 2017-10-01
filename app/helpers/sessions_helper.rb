module SessionsHelper

  # 登入指定的用户
  def log_in(user, authority)
    session[:user_id] = user.id
    session[:authority] = authority
  end

  # 返回当前登录的用户（如果有的话）
  def current_user
    authority = session[:authority]
    if authority == $customer
      @current_user ||= Customer.find_by(id: session[:user_id])
    elsif authority == $admin
      @current_user ||= Admin.find_by(id: session[:user_id])
    elsif authority == $superadmin
      @current_user ||= SuperAdmin.find_by(id: session[:user_id])
    end
  end

  def current_authority
    @authority = session[:authority]
  end

  # 如果用户已登录，返回 true，否则返回 false
  def logged_in?
    !current_user.nil?
  end
  def log_out
    session.delete(:user_id)
    session.delete(:authority)
    @current_user = nil
    @authority = nil
  end
end