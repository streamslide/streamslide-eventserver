require 'faye'

class ServerExt
  def incoming(message, request, callback)
    callback.call(message)
  end

  def outgoing(message, callback)
    callback.call(message)
  end
end

Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.add_extension(ServerExt.new)
run bayeux
