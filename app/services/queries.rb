module Queries
  class FetchData
    def self.call(params)
      query = params[:query]
      raise ArgumentError, 'missing query' unless query.present?

      options = params[:options] || {}

      Query::QUERY_TYPES.reduce({}) do |result, query_type|
        result[query_type] = query.query_params.map do |params|
          mc_query = MediaCloudQuery.new(params).build(query_type)
          mc_query.perform(options)
        end

        result
      end
    end
  end

  class DownloadFullData
    def self.call(params)
      query = params[:query]
      raise ArgumentError, 'missing query' unless query.present?

      return if query.full_data

      ActiveRecord::Base.transaction do
        query.data = Queries::FetchData.(query: query, options: { full: true })
        query.full_data = true
        query.save!
      end
    end
  end

  class Save
    def self.call(params)
      query = params[:query]
      raise ArgumentError, 'missing query' unless query.present?

      ActiveRecord::Base.transaction do
        query.data = Queries::FetchData.(query: query) if params[:fetch_data]
        query.save!
        query
      end
    end
  end
end
