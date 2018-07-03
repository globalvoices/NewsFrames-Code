LANGUAGES = CSV.read('config/languages.csv').map { |row| row.map(&:strip) }
