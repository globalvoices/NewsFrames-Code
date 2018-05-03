# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

class RootSiteAuth < Rack::Auth::Basic
  def call(env)
    request = Rack::Request.new(env)
    if ['/users/register'].include? request.path
      super
    else
      @app.call(env)
    end
  end
end

use RootSiteAuth, "Restricted Area" do |username, password|
  [username, password] == [ENV['RESTRICTED_ROUTE_USER'], ENV['RESTRICTED_ROUTE_PASSWORD']]
end

run Rails.application
