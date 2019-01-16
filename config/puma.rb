workers 2
threads 4, 16
port 9191

app_dir = File.expand_path("../..", _FILE_)
shared_dir = "#{app_dir}/shared"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

pidfile "#{shared_dir}/tmp/pids/puma.pid"
preload_app!

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

# Set up socket location
# bind "unix:///home/deploy/shared/sockets/single_tenant.sock"
#
# # Logging
# stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
#
# # Set master PID and state locations
# pidfile "/home/deploy/single_tenant/shared/tmp/pids/puma.pid"
# state_path "/home/deploy/shared/tmp/pids/puma.state"
# activate_control_app
