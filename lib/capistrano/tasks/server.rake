namespace :server do
  task :stop do
    on roles(:all) do
      execute "cd #{current_path}; bundle exec god status > /dev/null && bundle exec god terminate"
    end
  end

  task :start do
    on roles(:all) do
      execute "cd #{current_path}; bundle exec god -c config/god.rb"
    end
  end

  task :restart do
    on roles(:all) do
      invoke 'server:stop'
      invoke 'server:start'
    end
  end

  after 'deploy:finished', 'server:restart'

end
