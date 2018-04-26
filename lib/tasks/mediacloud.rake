namespace :mediacloud do
  desc 'Fetch MediaCloud data for all queries'
  task :fetch => :environment do
    Query.all.find_each do |query|
      puts "fetching data for query=#{query.id}..."
      Queries::DownloadFullData.(query: query)
    end

    puts 'OK'
  end

  desc 'Migrate Dashboard URLs to Explorer URLs'
  task :migrate_urls => :environment do
    query_regex = /query\/(?<keywords>[^\/]+)\/(?<media>[^\/]+)\/(?<start>[^\/]+)\/(?<end>[^\/]+)\/(?<meta>[^\/]+)\/?/

    ActiveRecord::Base.transaction do
      queries = Query.where('media_cloud_url ILIKE ?', 'https://dashboard.mediacloud.org%')
      queries.find_each do |query|
        fragment = query.media_cloud_url.split('#').last
        match = query_regex.match(fragment)
        if match
          keywords = JSON.parse(match[:keywords])
          media = JSON.parse(match[:media])
          start_dates = JSON.parse(match[:start])
          end_dates = JSON.parse(match[:end])
          meta = JSON.parse(match[:meta])

          results = keywords.zip(media, start_dates, end_dates, meta).map do |params|
            q, media, start_date, end_date, meta = params
            result = {
              'q' => q,
              'sources' => media['sources'] || [],
              'collections' => media['sets'] || [],
              'startDate' => Date.parse(start_date).strftime('%Y-%m-%d'),
              'endDate' => Date.parse(end_date).strftime('%Y-%m-%d'),
              'label' => meta['name'],
              'color' => "%23#{meta['color']}"
            }
          end

          url = "https://explorer.mediacloud.org/#/queries/search?q=#{results.to_json}"
          puts '---'
          puts query.media_cloud_url
          puts url

          query.media_cloud_url = url
          query.migrated = true
          query.save!
        end
      end
    end
  end
end
