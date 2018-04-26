class UserMailer < ApplicationMailer
  def admin(user_id, invitation_token)
    @user = User.find(user_id)
    @invitation_token = invitation_token
    mail(to: @user.email, subject: 'Admin')
  end

  def register(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'Welcome to NewsFrames')
  end

  def approved(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, subject: 'Your NewsFrames account has been approved')
  end

  def new_user_waiting_for_approval(user_id)
    admins = User.with_role :admin
    @user = User.find(user_id)
    mail(to: admins.map(&:email).uniq, subject: 'New signup, approval needed') if admins.present? and !@user.approved?
  end
end
