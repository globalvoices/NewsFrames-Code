class AddEtherpadToProject < ActiveRecord::Migration[5.0]
  def up
    add_column :projects, :pad_id, :string

    Project.find_each do |project|
      instance = EtherpadLite.connect(ENV['ETHERPAD_URL'], ENV['ETHERPAD_API_KEY'], '1.2.1')
      group = instance.create_group
      pad = group.create_pad('main')

      project.pad_id = pad.id
      project.save!
    end

    change_column :projects, :pad_id, :string, null: false
  end

  def down
    remove_column :projects, :pad_id
  end
end
