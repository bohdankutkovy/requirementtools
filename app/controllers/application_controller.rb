class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions
  include AclRedirectionHelper

  respond_to :html, :json

  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to root_url
  end

  rescue_from ActiveScaffold::ActionNotAllowed, with: :permission_denied

  rescue_from CanCan::AccessDenied do |exception|
    if logged_in? && current_user.info_edited
      redirect_to root_path, alert: exception.message
    else
      redirect_to new_user_session_path(return_to: url_for(params)), alert: exception.message
    end
  end

  def after_sign_in_path_for(resource)
    if current_user.info_edited == false
      edit_profile_path(current_user)
    else
      params[:return_to] || '/'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  def logged_in?
    user_signed_in?
  end
end
