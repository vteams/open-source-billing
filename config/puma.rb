workers 2
threads_count = 5
threads threads_count, threads_count
app_dir = File.expand_path("../..", __FILE__)

# Set up socket location
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

pidfile "#{app_dir}/tmp/pids/puma.pid"
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
