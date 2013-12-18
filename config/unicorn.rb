# http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

working_directory "/var/www/apps/errbit/current"
pid "/var/www/apps/errbit/current/tmp/pids/unicorn.pid"
stderr_path "/var/www/apps/errbit/current/log/unicorn.log"
stdout_path "/var/www/apps/errbit/current/log/unicorn.log"

listen 8099
worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
preload_app true

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "/var/www/apps/errbit/current/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.verify_active_connections!
end
