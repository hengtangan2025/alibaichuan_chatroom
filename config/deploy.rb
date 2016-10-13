require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'rails/generators'
require 'mina_util/builder'
require 'yaml'

set :domain, '42.120.41.92'
set :deploy_to, '/web/alibaichuan_chatroom'
set :current_path, 'current'
set :repository, 'https://github.com/hengtangan2025/alibaichuan_chatroom.git'
set :branch, 'master'
set :user, 'root'
set :term_mode, nil

set :shared_paths, [
  'config/mongoid.yml',
  'config/secrets.yml',
  'config/application.yml',
  'tmp',
  'log'
]

task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/logs"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/logs"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  #queue! %[touch "#{deploy_to}/shared/config/mongoid.yml"]
  order = MinaUtil::Builder.ask_mongoid('alibaichuan_chatroom')
  queue! %[echo '#{order}' > "#{deploy_to}/shared/config/mongoid.yml"]

  secrets = MinaUtil::Builder.ask_secrets
  queue! %[echo '#{secrets}' > "#{deploy_to}/shared/config/secrets.yml"]

  nginx = MinaUtil::Builder.ask_nginx('alibaichuan_chatroom', '/web/alibaichuan_chatroom')
  queue! %[echo '#{nginx}' > "/etc/nginx/conf.d/alibaichuan_chatroom.conf"]
  #test
  #queue! %[echo '#{nginx}' > "/home/dd/alibaichuan_chatroom.conf"]

  queue! %[touch "#{deploy_to}/shared/config/application.yml"]
  if File.exist? "config/application.yml.sample"
    figaro = MinaUtil::Builder.ask_figaro
    queue! %[echo '#{figaro}' > "#{deploy_to}/shared/config/application.yml"]
  else
    # 不处理
    queue  %[echo "未在本地发现 'config/application.yml.sample'."]
    queue  %[echo "略过figaro配置."]
  end

  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    to :launch do
      queue %[
        source /etc/profile
        bundle
        RAILS_ENV="production" bundle exec rake assets:precompile
        ./deploy/sh/unicorn.sh stop
        ./deploy/sh/unicorn.sh start
      ]
    end
  end

end

desc "update code only"
task :update_code => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    to :launch do
      queue %[
        source /etc/profile
        bundle
        RAILS_ENV="production" bundle exec rake assets:precompile
      ]
    end
  end
end

desc "restart server"
task :restart => :environment do
  queue %[
    source /etc/profile
    cd #{deploy_to}/#{current_path}
    ./deploy/sh/unicorn.sh stop
    ./deploy/sh/unicorn.sh start
  ]
end
