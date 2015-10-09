module Cef
  class Event < Hashie::Dash
    SCHEMA_CONFIG_FILE = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','conf','cef-schema.json')
    config = JSON.parse(File.read(SCHEMA_CONFIG_FILE))
    config['prefix'].each    {|a| self.class_eval { property a.to_sym, required: true }}
    config['extension'].each {|a| self.class_eval { property a.to_sym }}
  end
end