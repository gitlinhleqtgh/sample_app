class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)

  # GET /users or /users.json
  def index
    @users = User.paginate(page: params[:page])
  end

  # GET /users/1 or /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t("message_active")
      redirect_to root_path
    else
      flash.now[:danger] = t("message_register_error")
      render :new
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if @user.update(user_params)
      flash[:sucess] = t("profile_update_success")
      redirect_to @user
    else
      flash.now[:danger] = t("profile_update_faild")
      render :edit
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    if @user.destroy
      flash[:sucess] = t("user_deleted")
    else
      flash[:danger] = t("user_delete_faild")
    end
    redirect_to users_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_user
    return if @user = User.find_by(id: params[:id])

    flash[:danger] = t("no_user")
    redirect_to new_user_path
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # confirms a logged in user
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("please_login")
    redirect_to login_path
  end

  # confirms the correct user.
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
end
