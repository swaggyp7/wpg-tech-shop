class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    attributes = %i[name address city province postal_code email password password_confirmation current_password]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes - [:current_password])
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end
end
