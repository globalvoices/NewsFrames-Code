# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def admin_preview
    UserMailer.admin(User.last, 'abc')
  end

  def register_preview
    UserMailer.register(User.last)
  end

  def register_pre_approved_preview
    UserMailer.register(User.with_role(:admin).last)
  end

  def new_user_waiting_for_approval_preview
    UserMailer.new_user_waiting_for_approval(User.last)
  end

  def approved_preview
    UserMailer.approved(User.last)
  end
end