#!/bin/env ruby
begin

  require 'rubygems'
  require 'logger'
  require 'json'
  require 'yaml'
  require 'net/http'
  require_relative 'marathon-template/deploy'
  require_relative 'marathon-template/cron'
  require_relative 'marathon-template/options'

rescue Exception => e

  puts "Failure during requires..."
  puts e.message
  puts e.backtrace

end

module Marathon_template
  begin
    # Set up logging to STDOUT
    LOG = Logger.new(STDOUT) 

    # Get our config file
    config_path = ENV['MARATHON_TEMPLATE_CONFIG_PATH'] || '/etc/haproxy.yaml' 
    if ! File.exists? config_path
      abort LOG.info "No haproxy yaml configuration found at #{config_path}. Please see https://github.com/malnick/marathon_template/blob/master/ext/haproxy_example.yaml for an example"
    end

    # Create a usable hash of configuration 
    CONFIG = Marathon_template::Options.initialize(config_path)

    # TODO Marathon_template::Install.haproxy
    
    # Deploy haproxy.cfg 
    Marathon_template::Deploy.haproxy
    
    # Configure Cron Job
    Marathon_template::Cron.add
    
  rescue Exception => e
    puts "marathon-template failed to execute." 
    puts e.message
    puts e.backtrace
  end
end
