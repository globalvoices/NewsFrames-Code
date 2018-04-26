namespace :deploy do
  desc "Reload the database with seed data"
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        execute "cd #{current_path}; bundle exec rake db:seed"
      end
    end
  end

  after 'deploy:migrate', 'deploy:seed'
end