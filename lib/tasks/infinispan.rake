# Inspired by rabbitmq.rake the Redbox project at http://github.com/rick/redbox/tree/master
require 'fileutils'
require 'open-uri'
require 'pathname'

ISPN_INSTALL_DIR = ENV['ISPN_INSTALL_DIR'] || '/tmp/infinispan'
ISPN_VER = "15.0.0.Dev06"
ZIP_NAME = "infinispan-server-#{ISPN_VER}"

class InfinispanRunner
  def self.infinispan_dir
   ISPN_INSTALL_DIR+'/'+ZIP_NAME
  end

  def self.bin_dir
    infinispan_dir + '/bin'
  end

  def self.config
   # TODO remove this
    @config ||= if File.exist?(redis_dir + 'etc/redis.conf')
                  redis_dir + 'etc/redis.conf'
                else
                  redis_dir + '../etc/redis.conf'
                end
  end

  def self.dtach_socket
   # TODO remove this
   '/tmp/redis.dtach'
  end

  # Just check for existance of dtach socket
  def self.running?
   # TODO remove this
   File.exist? dtach_socket
  end

  def self.start
    sleep 1
    pid = spawn("#{bin_dir}/server.sh -c infinispan-resque.xml > /dev/null 2>&1")
    Process.detach(pid)
    exec "echo Infinispan server started... Check logs in #{infinispan_dir}/server/log if needed"
  end

  def self.stop
    exec "echo \"shutdown server\" | #{bin_dir}/cli.sh --connect http://127.0.0.1:11222"
  end
end


namespace :infinispan do
  desc 'About infinispan'
  task :about do
    puts "\nSee http://infinispan.org for information about Infinispan.\n\n"
  end

  desc 'Start Infinispan'
  task :start do
    InfinispanRunner.start
  end

  desc 'Stop Infinispan'
  task :stop do
    InfinispanRunner.stop
  end

  desc 'Restart Infinispan'
  task :restart do
    InfinispanRunner.stop
    InfinispanRunner.start
  end

  desc 'Attach to redis dtach socket'
  # TODO remove this
  task :attach do
    RedisRunner.attach
  end

  desc <<-DOC
  Install the latest version of Infinispan from infinispan.org (requires java).
    Use ISPN_INSTALL_DIR env var like "rake infinispan:install ISPN_INSTALL_DIR=~/tmp"
    in order to get an alternate location for your install files.
  DOC

  task :install => [:about, :download] do
    conf_dir = "#{ISPN_INSTALL_DIR}/#{ZIP_NAME}/server/conf"

    puts "Installed infinispan to #{ISPN_INSTALL_DIR}"

    unless File.exist?("#{conf_dir}/infinispan-resque.xml")
      sh "cp infinispan-resque.xml #{conf_dir}"
      puts "Installed infinispan-resque.xml to #{conf_dir} \n You should look at this file!"
    end
  end

  desc "Download package"
  task :download do
   sh "mkdir -p #{ISPN_INSTALL_DIR}" unless File.exist?("#{ISPN_INSTALL_DIR}")
   sh "wget -N https://downloads.jboss.org/infinispan/#{ISPN_VER}/#{ZIP_NAME}.zip -P #{ISPN_INSTALL_DIR}"
    sh "unzip  #{ISPN_INSTALL_DIR}/#{ZIP_NAME}.zip -d #{ISPN_INSTALL_DIR}"
  end
end
