require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'
require 'redis'
require 'pry'

class ServerAuth
  def initialize(rinstance)
    @rinstance = rinstance
  end

  def incoming(message, callback)
    print message
#    print "\n"
#    if message['channel'] !~ %r{^/meta/}
#      identifier = message['data']['identifier']
#
#      case identifier
#      when 'master'
#        master_check_routine(message)
#      when 'client'
#        normal_check_routine(message)
#      else
#        message['error'] = '[ErrorMessage] invalid identifier'
#      end
#    end
    p message
    callback.call(message)
  end

  def outgoing(message, callback)
    p message
#    if message['ext'] && message['ext']['auth_token']
#      message['ext'] = {}
#    end
#
#    if (message['data']['token'] != master_token)
#      message['error'] = '[ErrorMessage] Invalid authentication token'
#    end
#    message['data']['token'] = nil
  end

  def normal_check_routine(message)
    host = get_host_from_message(message)
    session_token = @rinstance.get "#{host}:streamslide:auth_key"

    if (message['data']['token'] != session_token)
      message['error'] = '[ErrorMessage] Invalid authentication token'
    end
    message['data']['token'] = nil
  end

  def get_host_from_message(mes)
    channel = mes['channel']
    return /\/(.*?)\//.match(channel).captures[0]
  end
end

Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)
faye_server.add_extension(ServerAuth.new($redis))
run faye_server
