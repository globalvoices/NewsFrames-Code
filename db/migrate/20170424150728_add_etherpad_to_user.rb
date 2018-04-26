class AddEtherpadToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :author_id, :string

    User.where(approved: true).find_each do |user|
      instance = EtherpadLite.connect(ENV['ETHERPAD_URL'], ENV['ETHERPAD_API_KEY'], '1.2.1')
      author = instance.create_author(name: user.name)
      user.author_id = author.id
      user.save!
    end
  end

  def down
    remove_column :users, :author_id
  end
end
