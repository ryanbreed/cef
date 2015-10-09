module Cef
  module Loggers
    class SyslogUdp
      SYSLOG_TIME_FORMAT = '%b %d %Y %H:%M:%S'
      SYSLOG_HEADER = '<%d>%s %s'


      attr_accessor :receiver, :port, :defaults
      attr_reader   :sock

      def initialize(*args)
        Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
        @receiver ||= '127.0.0.1'
        @port     ||= 514
        @defaults ||= {}
        @sock = UDPSocket.new
        @sock.connect(@receiver, @port)
        self
      end

      def header(facility=0,priority=0)
        format(SYSLOG_HEADER,
               131,                                    # facility|priority
               Time.new.strftime(SYSLOG_TIME_FORMAT),  # now
               Socket::gethostname)                    # hostname
      end

      def formatted_message(event)
        format('%s %s', header, event.to_cef )
      end

      def emit(*events)
        events.each do |event|
          defaults.each {|k,v| event.send(format("%s=",k),v) }
          sock.send(formatted_message(event),0)
        end
      end
    end
  end
