set :branch, ENV['BRANCH'] || :master

server ENV['HOST'], user: ENV['USER'], roles: %w{app db web}, primary: true
