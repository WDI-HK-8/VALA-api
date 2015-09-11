class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  
  def configure_permitted_parameters
    common_fields = [:first_name, :last_name, :profile_picture, :phone_number]
    if resource_class == User
      devise_parameter_sanitizer.for(:sign_up) << common_fields + [:car_picture, :car_color, :car_make, :car_license_plate, :is_manual, :manual]
    elsif resource_class == Valet
      devise_parameter_sanitizer.for(:sign_up) << common_fields + [:HKID, :driver_license_expiry_date, :years_of_driving, :manual, :status]
      devise_parameter_sanitizer.for(:account_update) << [:profile_picture, :phone_number, :driver_license_expiry_date, :years_of_driving, :manual, :status]
    end
  end
end
