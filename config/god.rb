RAILS_ROOT = File.dirname(File.dirname(__FILE__))

PID_FILE = "#{RAILS_ROOT}/tmp/pids/server.pid"

God.watch do |w|
  w.name = 'rails'

  w.dir = RAILS_ROOT
  w.start = "bundle exec rails server -d"
  w.restart = "touch #{RAILS_ROOT}/tmp/restart.txt"
  w.stop = "kill $(cat #{PID_FILE})"

  w.pid_file = PID_FILE

  w.interval = 60.seconds
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end
end
