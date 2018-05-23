class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  rescue_from ActionController::ParameterMissing, with: :param_missing

  before_action :set_locale

  private

  def set_locale(user = nil)
    user ||= current_user
    if user.present?
      begin
        I18n.locale = ISO_639.find(user.language).try(:alpha2) || I18n.default_locale
      rescue I18n::InvalidLocale
        I18n.locale = I18n.default_locale
      end
    else
      I18n.locale = I18n.default_locale
    end
  end

  # Error handling

  def not_authorized(user)
    if current_user.present?
      flash[:error] = 'You are not authorized to perform this action'
      redirect_to root_path
    else
      flash[:error] = 'You must be logged in first'
      redirect_to new_user_session_path
    end
  end

  def param_missing
    flash[:error] = 'Missing parameter'
    redirect_to root_path
  end
end
