module CEF
  class Event
    attr_accessor :syslog_pri, :event_time, :my_hostname
    # set up accessors for all of the CEF event attributes. ruby meta magic.
    CEF::ATTRIBUTES.each do |k,v|
      self.instance_eval do
        attr_accessor k
      end
    end

    def attrs
      CEF::ATTRIBUTES
    end
  
    # so we can CEF::Event.new(:foo=>"bar")
    def initialize( *params )
      @event_time         = Time.new
      @deviceVendor       = "breed.org"
      @deviceProduct      = "CEF"
      @deviceVersion      = CEF::VERSION
      @deviceEventClassId = "0:event"
      @deviceSeverity     = CEF::SEVERITY_LOW
      @name               = "unnamed event"
      # used to avoid requiring syslog.h on windoze
      #syslog_pri= Syslog::LOG_LOCAL0 | Syslog::LOG_NOTICE
      @syslog_pri         = 131
      @my_hostname        = Socket::gethostname
      @other_attrs={}
      @additional={}
      Hash[*params].each { |k,v| self.send("%s="%k,v) }
      yield self if block_given?
      self
    end
  
    # returns a cef formatted string
    def to_s
      log_time=event_time.strftime(CEF::LOG_TIME_FORMAT)
      
      sprintf(
        CEF::LOG_FORMAT,
        syslog_pri.to_s,
        log_time,
        my_hostname,
        format_prefix,
        format_extension
      )
    end

    # used for non-schema fields
    def set_additional(k,v)
      @additional[k]=v
    end
    def get_additional(k,v)
      @additional[k]
    end

    #private
      # make a guess as to how the time was set. parse strings and convert
      # them to epoch milliseconds, or leave it alone if it looks like a number
      # bigger than epoch milliseconds when i wrote this.
      # def time_convert(val)
      #
      #   converted=case val
      #     when String
      #       if val.match(%r{\A[0-9]+\Z})
      #         converted=val.to_i
      #       else
      #         res=Chronic.parse(val)
      #         converted=Time.at(res).to_i * 1000
      #       end
      #     when Integer,Bignum
      #       if val < 1232589621000 #Wed Jan 21 20:00:21 -0600 2009
      #         val * 1000
      #       else
      #         val
      #       end
      #     end
      #
      # end

      # escape only pipes and backslashes in the prefix. you bet your sweet
      # ass there's a lot of backslashes in the substitution. you can thank
      # the three levels of lexical analysis/substitution in the ruby interpreter
      # for that.

      def escape_prefix_value(val)
        escapes={
          %r{(\||\\)} => '\\\\\&'
        }
        escapes.reduce(val) do|memo,replace|
          memo=memo.gsub(*replace)
        end
      end

      # only equals signs need to be escaped in the extension. i think.
      # TODO: something in the spec about \n and some others.
      def escape_extension_value(val)
        escapes = {
          %r{=}  => '\=',
          %r{\n} => ' ',
          %r{\\} => '\\'
        }
        escapes.reduce(val) do |memo,replace|
          memo=memo.gsub(*replace)
        end
      end

      # returns a pipe-delimeted list of prefix attributes
      def format_prefix
        values = CEF::PREFIX_ATTRIBUTES.keys.map { |k| self.send(k) }
        escaped = values.map do |value|
          escape_prefix_value(value)
        end
        escaped.join('|')
      end

      # returns a space-delimeted list of attribute=value pairs for all optionals
      def format_extension
        extensions = CEF::EXTENSION_ATTRIBUTES.keys.map do |meth|
          value = self.send(meth)
          next if value.nil?
          shortname = CEF::EXTENSION_ATTRIBUTES[meth]
          [shortname, escape_extension_value(value)].join("=")
        end

        # make sure time comes out as milliseconds since epoch
        times = CEF::TIME_ATTRIBUTES.keys.map do |meth|
          value = self.send(meth)
          next if value.nil?
          shortname = CEF::TIME_ATTRIBUTES[meth]
          [shortname, escape_extension_value(value)].join("=")
        end
        (extensions + times).compact.join(" ")
      end
  end
end

        # vendor=  self.deviceVendor       || "Breed"
        # product= self.deviceProduct      || "CEF Sender"
        # version= self.deviceVersion      || CEF::VERSION
        # declid=  self.deviceEventClassId || "generic:0"
        # name=    self.name               || "Generic Event"
        # sev=     self.deviceSeverity     || "1"
        # %w{ deviceVendor deviceProduct deviceVersion deviceEvent}
        # cef_prefix="%s|%s|%s|%s|%s|%s" % [
        #   prefix_escape(vendor),
        #   prefix_escape(product),
        #   prefix_escape(version),
        #   prefix_escape(declid),
        #   prefix_escape(name),
        #   prefix_escape(sev),
        # ]