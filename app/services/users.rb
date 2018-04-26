module Users
  class Approve
    def self.call(params)
      user = params[:user]
      raise ArgumentError, 'missing user' unless user.present?

      return user if user.approved?

      ActiveRecord::Base.transaction do
        unless user.author_id.present?
          author = Etherpad::CreateAuthor.()
          user.author_id = author.id
        end

        user.approved = true
        user.save!
      end

      UserMailer.approved(user.id).deliver_now unless params[:skip_email]

      user
    end
  end

  class Enable
    def self.call(params)
      user = params[:user]
      raise ArgumentError, 'missing user' unless user.present?

      return user if user.enabled?

      user.enabled = true
      user.save!
    end
  end

  class Disable
    def self.call(params)
      user = params[:user]
      raise ArgumentError, 'missing user' unless user.present?

      return user unless user.enabled?

      user.enabled = false
      user.save!
    end
  end

  class FindByEmails
    def self.call(params)
      emails = params[:emails]
      raise ArgumentError, 'missing emails' unless emails.present?

      return [] unless emails.present?

      users = []
      emails.each do |email|
        users << { email: email, user: User.find_by(email: email) }
      end

      users
    end
  end
end
