module Etherpad
  extend self

  def instance
    @instance ||= EtherpadLite.connect(ENV['ETHERPAD_URL'], ENV['ETHERPAD_API_KEY'], '1.2.1')
  end

  class CreatePad
    def self.call(params = {})
      name = params[:name]
      raise ArgumentError, 'missing name' unless name.present?

      group = Etherpad.instance.create_group
      group.create_pad(name)
    end
  end

  class GetPad
    def self.call(params)
      pad_id = params[:pad_id]
      raise ArgumentError, 'missing pad_id' unless pad_id.present?

      Etherpad.instance.get_pad(pad_id)
    end
  end

  class DeletePad
    def self.call(params)
      pad_id = params[:pad_id]
      raise ArgumentError, 'missing pad_id' unless pad_id.present?

      pad = Etherpad.instance.get_pad(pad_id)
      group = pad.group
      pad.delete
      group.delete
    end
  end

  class CreateAuthor
    def self.call
      Etherpad.instance.create_author
    end
  end

  class CreateSession
    def self.call(params)
      author_id = params[:author_id]
      raise ArgumentError, 'missing author_id' unless author_id.present?

      group_id = params[:group_id]
      raise ArgumentError, 'missing group_id' unless group_id.present?

      author = Etherpad.instance.get_author(author_id)
      group = Etherpad.instance.get_group(group_id)
      group.create_session(author, 60 * 24) # valid for 24 hours
    end
  end

  class GetSession
    def self.call(params)
      session_id = params[:session_id]
      raise ArgumentError, 'missing session_id' unless session_id.present?

      session = Etherpad.instance.get_session(session_id)

      if session.expired?
        session.delete
        nil
      else
        session
      end
    rescue EtherpadLite::Error
      nil
    end
  end

  class SessionManager
    attr_reader :sessions

    def initialize(sessions, &saver)
      @sessions = sessions || {}
      @saver = saver
    end

    def save
      @saver.call(sessions)
    end

    def start_session(id, pad_id, author_id)
      cleanup(id)

      unless exists?(id)
        pad = Etherpad::GetPad.(pad_id: pad_id)
        session = Etherpad::CreateSession.(author_id: author_id, group_id: pad.group.id)
        sessions[id] = session.id
      end

      sessions[id]
    end

    def start_session!(id, pad_id, author_id)
      session_id = start_session(id, pad_id, author_id)
      save
      session_id
    end

    private

    def cleanup(id)
      return unless exists?(id)
      session = Etherpad::GetSession.(session_id: sessions[id])
      clear(id) unless session.present?
    end

    def exists?(id)
      sessions[id].present?
    end

    def clear(id)
      sessions[id] = nil
    end
  end
end
