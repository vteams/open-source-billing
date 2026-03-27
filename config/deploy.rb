# config valid only for current version of Capistrano
# lock '3.6.1'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rvm_ruby_version, '2.7.1'
set :rvm_binary, '/usr/local/rvm/bin/rvm'
set :use_sudo, false

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/config.yml', 'Gemfile.lock', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'tmp/pids'#,'log', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for keep_releases is 5
set :keep_releases, 5

set :default_shell, '/bin/bash -l'

namespace 'deploy' do
  desc "Start the application"
  task :start do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=production #{fetch(:rvm_binary)} #{fetch(:rvm_ruby_version)} do bundle exec puma -p 9191 -d"
    end
  end

  desc "Stop the application"
  task :stop do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=production #{fetch(:rvm_binary)} #{fetch(:rvm_ruby_version)} do bundle exec pumactl -P tmp/pids/puma.pid stop"
    end
  end

  desc "Restart the application"
  task :restart do
    on roles(:app) do
      execute "cd #{current_path} && RAILS_ENV=production #{fetch(:rvm_binary)} #{fetch(:rvm_ruby_version)} do bundle exec pumactl -P tmp/pids/puma.pid restart"
    end
  end

  desc 'Install JS dependencies with Yarn'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        # Adjust this if Yarn is installed via NVM or custom path
        execute "/home/dev/.nvm/versions/node/v18.20.8/bin/yarn install --silent --no-progress"
      end
    end
  end
end
before 'deploy:assets:precompile', 'deploy:yarn_install'
after 'deploy:finishing', 'deploy:restart'
