class AddFullDataToQueries < ActiveRecord::Migration[5.0]
  class Query < ActiveRecord::Base; end

  def up
    add_column :queries, :full_data, :boolean, null: false, default: false

    Query.all.find_each do |query|
      query.full_data = true
      query.save!
    end
  end

  def down
    remove_column :queries, :full_data
  end
end
