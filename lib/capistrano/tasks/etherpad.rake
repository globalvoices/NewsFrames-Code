namespace :etherpad do
  task :stop do
    on roles(:all) do
      execute "ps aux | grep 'node_modules/ep_etherpad-lite/node/server.js' | awk '{ print $2 }' | xargs kill -9"
    end
  end

  task :start do
    on roles(:all) do
      execute "nohup bash -l -c 'cd #{current_path}/../.. && etherpad/bin/run.sh&' > /dev/null 2>&1"
    end
  end

  task :restart do
    on roles(:all) do
      invoke 'etherpad:stop'
      invoke 'etherpad:start'
    end
  end

  task :deploy do
    on roles(:all) do
      execute "bash -l -c 'cd #{current_path}/../.. && rm -rf etherpad/node_modules/ep_gv_insert_image && cp -R #{current_path}/etherpad_plugins/ep_gv_insert_image etherpad/node_modules/ep_gv_insert_image/' > /dev/null 2>&1"
      execute "bash -l -c 'cd #{current_path}/../.. && rm -rf etherpad/node_modules/ep_gv_show_progress_bar && cp -R #{current_path}/etherpad_plugins/ep_gv_show_progress_bar etherpad/node_modules/ep_gv_show_progress_bar/' > /dev/null 2>&1"
    end
  end

  after 'deploy:publishing', 'etherpad:deploy'
  after 'deploy:finished', 'etherpad:restart'

end
