# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'faucet'
set :repo_url, 'git@github.com:AlexChien/web_services.git'
set :repo_tree, 'faucet'
set :deploy_to,   "/usr/local/www/#{fetch(:application)}"

set :keep_releases, 5
set :user,        "runner"

# rvm
# set :rvm_ruby_string, '2.1.5@acgpd'
set :rvm_ruby_version, '2.1@faucet'
set :rvm_type, :user

# passenger
set :passenger_roles, :app
set :passenger_restart_runner, :sequence
set :passenger_restart_wait, 5
set :passenger_restart_limit, 2

set :linked_files, %w{config/database.yml config/bitshares.yml config/secrets.yml}
set :config_files, %w{database.yml bitshares.yml}

set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :executable_config_files, %w{}
set :symlinks, %w{}

namespace :deploy do

  desc 'Warm up the application by pinging it, so enduser wont have to wait'
  task :ping do
    on roles(:app), in: :sequence, wait: 5 do
      execute "curl -s -D - #{fetch(:domain)} -o /dev/null"
    end
  end

  after :restart, :ping

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc "build missing paperclip styles"
  task :build_missing_paperclip_styles do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:stage) do
          rake 'paperclip:refresh:missing_styles'
        end
      end
    end
  end
  # after "deploy:compile_assets", "deploy:build_missing_paperclip_styles"

end

task :whoami do
  on roles(:all) do
    execute :whoami
  end
end

task :query_interactive do
  on fetch(:ip) do
    info capture("[[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'")
  end
end

task :query_login do
  on fetch(:ip) do
    info capture("shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'")
  end
end

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
