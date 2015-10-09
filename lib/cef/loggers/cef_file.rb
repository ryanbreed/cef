module CEF
  module Loggers
    class CefFile
      attr_accessor :path, :defaults, :append
      attr_reader   :fh
      def initialize(*args)
        Hash[*args].each {|k,v| self.send(format('%s=',k),v)}
        @defaults ||= {}
        @path     ||= 'cef.log'
        @append   = false if @append.nil?
        @fh = File.open(path, append ? 'w+' : 'w')
        self
      end
      def emit(*events)
        events.each {|e| fh.puts(e.to_cef)}
      end
    end
  end
end
