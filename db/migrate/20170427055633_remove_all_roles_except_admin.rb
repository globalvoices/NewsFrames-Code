class RemoveAllRolesExceptAdmin < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      if (user.admin?)
        user.roles = []
        user.add_role :admin
        user.save!
      else
        user.roles = []
        user.save!
      end
    end

    Role.all.each do |role|
      if (role.name.to_sym != :admin)
        role.destroy
      end
    end
  end
end
