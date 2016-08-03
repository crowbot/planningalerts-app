# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'planningalerts'
set :repo_url, 'git://github.com/crowbot/planningalerts-app.git'

# Default branch is :master
set :branch, 'southwark'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/srv/www/planningalerts'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/general.yml', 'config/test.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p648'


namespace :git do
  desc 'Copy repo to releases'
  task create_release: :'git:update' do
    on roles(:all) do
      with fetch(:git_environmental_variables) do
        within repo_path do
          execute :git, :clone, '-b', fetch(:branch), '--recursive', '.', release_path
        end
      end
    end
  end
end