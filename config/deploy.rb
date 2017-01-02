# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'osb'
set :repo_url, 'git@gitlab.vteamslabs.com:vteams/v_billing.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
#set :deploy_to, '/home/deploy/multi_tenants'

set :deploy_to, '/home/osbstage/apps/multi_tenants'
# Default value for :scm is :git
# set :scm, :git
set :rvm_ruby_version, '2.0.0-p648'
# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true
set :use_sudo,        false
# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/config.yml', 'config/application.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :rails_env, fetch(:stage)
# Default value for keep_releases is 5
set :keep_releases, 5