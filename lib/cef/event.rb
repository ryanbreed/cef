module Cef
  class Event < Hashie::Dash
    include Hashie::Extensions::Coercion
    LOG_FORMAT      = '<%d>%s %s CEF:0|%s|%s'
    LOG_TIME_FORMAT = '%b %d %Y %H:%M:%S'

    PREFIX_KEYS = [ :deviceVendor, :deviceProduct, :deviceVersion, :deviceEventClassId, :name, :deviceSeverity]
    EXTENSION_ESCAPES = {
      %r{=}  => '\=',
      %r{\n} => '\n',
      %r{\r} => '\r',
      %r{\\} => '\\'
    }

    PREFIX_ESCAPES = {
      %r{(\||\\)} => '\\\\\&'
    }

    SCHEMA_CONFIG_FILE = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','conf','cef-schema.json')
    config = JSON.parse(File.read(SCHEMA_CONFIG_FILE))

    if ENV['CEF_CONFIG']!=nil && File.exist?(ENV['CEF_CONFIG'])
      overrides = JSON.parse(File.read(ENV['CEF_CONFIG']))
      config.merge!(overrides)
    end
    CEF_SCHEMA = config

    config['prefix'].each    do |json_key, default_val|
      self.class_eval do
        key = json_key.to_sym
        property key, { default: default_val, required: true }
      end
    end

    config['extension'].each do |key|
      self.class_eval { property key.to_sym }
    end

    config['types'].each do |key,klass_name|
      self.class_eval { coerce_key key.to_sym, Module.const_get(klass_name) }
    end

    def to_cef
      if extension_data == {}
        format('%s|',format_prefix)
      else
        format('%s|%s',format_prefix,format_extension)
      end
    end

    def format_prefix
      prefix_values.map { |value| escape_prefix_value(value) }.join('|')
    end

    def prefix_values
      [ 'CEF:0', *PREFIX_KEYS.map {|k| self.send(k) } ]
    end

    def format_extension
      extension_keys.zip(extension_values)
                    .map {|k,v| format('%s=%s',k,v)}
                    .join(' ')
    end

    def extension_keys
      extension_data.keys.map {|k| CEF_SCHEMA["key_names"].fetch(k.to_s,k.to_s)}
    end

    def extension_values
      extension_data.values.map {|v| escape_extension_value(v)}
    end

    def extension_data
      self.to_h.reject {|k,v| PREFIX_KEYS.include?(k)}
    end

    def escape_prefix_value(val)
      case val
        when String
          PREFIX_ESCAPES.reduce(val) do|memo,replace|
            memo=memo.gsub(*replace)
          end
        else
          val.to_s
      end
    end

    def escape_extension_value(val)
      case val
        when String
          EXTENSION_ESCAPES.reduce(val) do |memo,replace|
            memo=memo.gsub(*replace)
          end
        when Time
          val.to_i * 1000
        else
          val.to_s
      end
    end
  end
end
