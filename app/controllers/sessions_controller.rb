class SessionsController < Devise::SessionsController
  skip_before_filter :allow_params_authentication!, only: [:create]

  def create
    if Rails.env.development? or verify_recaptcha(model: resource)
      allow_params_authentication!
      super
    else
      self.resource = resource_class.new(sign_in_params)
      render :new
    end
  end
end
