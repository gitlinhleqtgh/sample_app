class SessionsController < ApplicationController
  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      activated
    else
      flash.now[:danger] = t("danger_login")
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
