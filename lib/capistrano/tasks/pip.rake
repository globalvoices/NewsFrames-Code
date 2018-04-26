namespace :deploy do
  desc "Install bias detector requirements"
  task :pip do
    on roles(:app) do
      execute "cd #{current_path}; pip install --user -r bias-detector/requirements.txt"
    end
  end

  after 'deploy:updated', 'deploy:pip'
end