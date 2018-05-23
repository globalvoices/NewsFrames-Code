class UsersController < Devise::RegistrationsController

  def create
    super do |user|
      if user.persisted?
        UserMailer.register(user.id).deliver_now
        UserMailer.new_user_waiting_for_approval(user.id).deliver_now
      end
    end
  end

  def update
    super do |user|
      set_locale(user)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation).merge(name_required: true)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :initials, :language, :password, :password_confirmation, :current_password).merge(name_required: true)
  end

end
