class ProfilesController < ApplicationController

  before_filter :set_user, only: [:show, :edit, :update]

  def show
    authorize! :read, @user
  end

  def edit
    authorize! :update, @user
    if !current_user.info_edited
      flash[:notice] = "Edit your password!"
    end
  end

  def update
    authorize! :update, @user
    if @user.update_attributes(user_params)
      if current_user.is_super_admin
        sign_in(current_user, bypass: true)
        flash[:notice] = "Profile updated!"
        redirect_to profile_path(@user)
      else
        sign_in(@user, bypass: true)
        flash[:notice] = "Profile updated!"
        redirect_to profile_path
      end
    else
      render :edit
    end
  end

  def set_user
    @user = User.find_by_id(params[:id])
  end

  def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :avatar_cache, :remove_avatar, :avatar)
  end
end
