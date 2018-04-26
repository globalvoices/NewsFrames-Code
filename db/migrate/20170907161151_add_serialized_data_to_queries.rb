class AddSerializedDataToQueries < ActiveRecord::Migration[5.0]
  class Query < ActiveRecord::Base; end

  def up
    add_column :queries, :serialized_data, :bytea

    Query.all.find_each(batch_size: 1) do |query|
      query.serialized_data =  ActiveSupport::Gzip.compress(JSON.dump(query.data))
      query.save!
    end

    remove_column :queries, :data
  end

  def down
    add_column :queries, :data, :jsonb

    Query.all.find_each(batch_size: 1) do |query|
      query.data =  JSON.parse(ActiveSupport::Gzip.decompress(query.serialized_data))
      query.save!
    end

    remove_column :queries, :serialized_data
  end
end
