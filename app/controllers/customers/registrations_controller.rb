class Customers::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    if params[:password].present? || params[:password_confirmation].present? || params[:email] != resource.email
      super
    else
      resource.update_without_password(params.except(:current_password))
    end
  end

  def after_update_path_for(resource)
    edit_customer_registration_path
  end
end
