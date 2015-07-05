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

  LOG = Logger.new(STDOUT) 
  config_path = ENV['MARATHON_TEMPLATE_CONFIG_PATH'] || '/etc/haproxy.yaml'
  CONFIG = Marathon_template::Options.initialize(config_path)
  Marathon_template::Deploy.haproxy(CONFIG)
  
  # TODO add in a cron job for every minute refresh of Deploy class if the cron job does not already exist
  
rescue Exception => e
  puts e.backtrace
  puts e.message
end
