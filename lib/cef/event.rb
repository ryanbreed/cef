module Cef
  class Event < Hashie::Dash
    include Hashie::Extensions::Coercion

    SCHEMA_CONFIG_FILE = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','conf','cef-schema.json')
    config = JSON.parse(File.read(SCHEMA_CONFIG_FILE))

    if ENV['CEF_CONFIG']!=nil && File.exist?(ENV['CEF_CONFIG'])
      overrides = JSON.parse(File.read(ENV['CEF_CONFIG']))
      config.merge!(overrides)
    end

    config['prefix'].each    do |key, default_val| 
      self.class_eval do
        # TODO: this is getting lost
        puts "setting prefix #{key} default #{default_val}"
        property key.to_sym, { default: default_val
      end
    end

    config['extension'].each do |key| 
      self.class_eval { property key.to_sym }
    end
  end
end