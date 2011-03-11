module CEF
  require 'socket'

  class Sender
    attr_accessor :receiver, :receiverPort, :eventDefaults
    attr_reader   :sock
    def initialize(*args)
      Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }
      @sock=nil
    end
  end

  #TODO: Implement relp/tcp senders

  class UdpSender < Sender

    #fire the message off
    def emit(event)
      self.socksetup if self.sock.nil?
      # process eventDefaults - we are expecting a hash here. These will
      # override any values in the events passed to us. i know. brutal.
      unless self.eventDefaults.nil?
        self.eventDefaults.each do |k,v|
          event.send("%s=" % k,v)
        end
      end
      self.sock.send event.format_cef, 0
    end

    private
      def socksetup
        @sock=UDPSocket.new
        receiver= self.receiver || "127.0.0.1"
        port= self.receiverPort || 514
        @sock.connect(receiver,port)
      end
  end
end