class AddEnabledToUsers < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
    self.table_name = 'users'
  end

  def change
    add_column :users, :enabled, :boolean, default: true, null: false
    add_index :users, :enabled

    User.all.each do |user|
      user.enabled = true
      user.save!
    end
  end
end
