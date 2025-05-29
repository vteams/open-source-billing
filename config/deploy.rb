# config valid only for current version of Capistrano
# lock '3.6.1'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rvm_ruby_version, '2.3.7'
set :rvm_binary, '/home/deploy/.rvm/bin/rvm'
set :use_sudo, false

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/config.yml', 'config/client_secret.json', 'config/gmail_token.yaml'

# Default value for linked_dirs is []
append :linked_dirs, 'tmp/pids'#,'log', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for keep_releases is 5
set :keep_releases, 5

set :default_shell, '/bin/bash -l'

namespace 'deploy' do
  desc "Start the application"
  task :start do
    on roles(:app) do
      execute :sudo, '/usr/bin/systemctl', :start, 'puma.service'
    end
  end

  desc "Stop the application"
  task :stop do
    on roles(:app) do
      execute :sudo, '/usr/bin/systemctl', :stop, 'puma.service'
    end
  end

  desc "Restart the application"
  task :restart do
    on roles(:app) do
      execute :sudo, '/usr/bin/systemctl', :restart, 'puma.service'
    end
  end
end

after 'deploy:finishing', 'deploy:restart'
