# config valid only for current version of Capistrano
# lock '3.6.1'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rvm_ruby_version, '2.3.7'

set :use_sudo, false

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/config.yml', 'Gemfile.lock'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for keep_releases is 5
set :keep_releases, 5

namespace 'deploy' do
  task :restart do
    "bundle exec puma -p 9191 -e production -d 'cat /home/deploy/single_tenant/shared/config/puma.pid' restart"
  end
end

after 'deploy:restart'
