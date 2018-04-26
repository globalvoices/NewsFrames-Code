module EtherpadConcern
  extend ActiveSupport::Concern

  def start_etherpad_session(project_pad)
    manager = Etherpad::SessionManager.new(session[:etherpad_sessions]) do |sessions|
      session[:etherpad_sessions] = sessions
    end

    compound_id = "#{project_pad.project.id}-#{project_pad.id}"
    session_id = manager.start_session!(compound_id, project_pad.pad_id, current_user.author_id)

    # This will be picked up by the client-side code
    cookies[:sessionID] = { value: session_id, domain: ENV['ETHERPAD_DOMAIN'] }
  end
end
