require 'json'
require 'date'
require 'socket'
require 'hashie'
require 'ipaddr'

require 'cef/version'
require 'cef/time_extensions'
require 'cef/event'
require 'cef/loggers/cef_file'
require 'cef/loggers/cef_syslog_udp'


module CEF
  def self.logger(config: {}, type: CEF::Loggers::SyslogUdp)
    configuration = case config
      when String && File.exist?(config)
        JSON.parse(File.read(config))
      when Hash
        config
      when File,IO
        JSON.parse(config.read)
      else
        fail ArgumentError, "#{config} is not a valid CEF configuration"
    end
        
    type.new(configuration)
  end
  def self.event(*args)
    CEF::Event.new(*args)
  end
end
