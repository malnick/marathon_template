#!/bin/env ruby

begin

  require 'rubygems'
  require 'logger'
  require 'json'
  require 'yaml'
  require 'optparse'
  require 'fileutils'
  require 'net/http'

  # Require all my libs
  library_files = Dir[File.join(File.dirname(__FILE__), "*.rb")].sort
  library_files.each do |f|
    require f
  end

rescue Exception => e

  puts "Failure during requires..."
  puts e.message
  puts e.backtrace

end

begin
  # Set up logging to STDOUT
  LOG = Logger.new(STDOUT) 
  
  # Get our config file
  config_path = ENV['MARATHON_TEMPLATE_CONFIG_PATH'] || '/etc/haproxy.yaml' 
  
  # Create a usable hash of configuration 
  CONFIG = Marathon_template::Options.initialize(config_path)

  # TODO Marathon_template::Install.haproxy
  
  # Deploy haproxy.cfg 
  Marathon_template::Deploy.haproxy
  
  # Configure Cron Job
  Marathon_template::Cron.add
  
rescue Exception => e
  puts e.backtrace
  puts e.message
end
