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
      when String
        JSON.parse(File.read(config))
      when Hash
        config
      when File,IO
        JSON.parse(config.read)
      else
        fail ArgumentError, "#{config} is not a valid CEF configuration"
    end
        
    logger_type = case type
      when Class
        type
      when String
        Module.const_get(type)
      else
        fail ArgumentError, "#{type} is not a valid class"
    end

    logger_type.new(configuration)
  end
  def self.event(*args)
    CEF::Event.new(*args)
  end
end
