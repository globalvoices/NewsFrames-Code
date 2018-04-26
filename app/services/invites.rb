module Invites
  class Create
    def self.call(params)
      email = params[:email]
      raise ArgumentError, 'missing email' unless email.present?

      user = User.invite!(email: email, name: params[:name]) do |user|
        user.skip_invitation = true if params[:skip_email]
      end

      user
    end
  end

  class AddAdmin
    def self.call(params)
      email = params[:email]
      raise ArgumentError, 'missing email' unless email.present?

      ActiveRecord::Base.transaction do
        user = User.find_by(email: email)
        if user.present?
          user.add_role(:admin)
          user.save!

          Users::Approve.(user: user, skip_email: true)
        else
          name = params[:name]
          raise ArgumentError, 'missing name' unless name.present?

          user = Invites::Create.(email: email, name: name, skip_email: true)
          user.add_role(:admin)
          user.save!

          Users::Approve.(user: user, skip_email: true)
        end

        raise 'Unable to invite user' if user.nil? or user.new_record?

        UserMailer.admin(user.id, user.raw_invitation_token).deliver_now

        user
      end
    end
  end
end
