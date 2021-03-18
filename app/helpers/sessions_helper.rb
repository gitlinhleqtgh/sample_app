module SessionsHelper
  # Log in the given user
  def log_in user
    session[:user_id] = user.id
  end

  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by id: user_id
    elsif user_id = cookies.signed[user_id]
      user = User.find_by id: user_id
      if user&.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Remembers a user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def remember_or_foget user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end

  def current_user? user
    user == current_user
  end

  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def admin_or_user user
    return unless current_user.admin? && !current_user?(user)

    link_to "delete", user, method: :delete,
      data: {confirm: t("are_you_sure")}
  end

  def activated user
    if user.activated?
      log_in user
      remember_or_foget user
      redirect_back_or user
    else
      flash.now[:danger] = t("message_active")
      redirect_to root_url
    end
  end
end
