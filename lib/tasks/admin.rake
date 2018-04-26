namespace :admin do
  desc 'Invite new or existing user to be an administrator (options: name=<new user name>, email=<new or existing user email>)'
  task :invite_admin => :environment do
    name  = ENV['name']
    email = ENV['email']
    Invites::AddAdmin.(name: name, email: email)
    puts 'OK'
  end
end