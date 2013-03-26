require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    print message
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != ENV['FAYE_TOKEN']
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {} 
      end
      callback.call(message)
    end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new)
run faye_server
