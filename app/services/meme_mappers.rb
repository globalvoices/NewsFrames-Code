module MemeMappers
  class FetchData
    def self.call(params)
      meme_mapper = params[:meme_mapper]
      raise ArgumentError, 'missing meme_mapper' unless meme_mapper.present?

      tineye = Tinplate::TinEye.new
      results = tineye.search(image_url: meme_mapper.image_url)
    end
  end

  class Save
    def self.call(params)
      meme_mapper = params[:meme_mapper]
      raise ArgumentError, 'missing meme_mapper' unless meme_mapper.present?

      ActiveRecord::Base.transaction do
        meme_mapper.data = MemeMappers::FetchData.(meme_mapper: meme_mapper) if params[:fetch_data]
        meme_mapper.save!
        meme_mapper
      end
    end
  end
end
