module CEF
  class Event
    attr_accessor :my_hostname, :syslog_pri, :event_time
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
      Hash[*params].each { |k,v| self.send("%s="%k,v) }

      @my_hostname ||= Socket::gethostname
      # used to avoid requiring syslog.h on windoze
      #syslog_pri= Syslog::LOG_LOCAL0 | Syslog::LOG_NOTICE
      @syslog_pri  ||= 131
      @other_attrs={}
      @additional={}
    end
  
    # returns a cef formatted string
    def format_cef
      log_time=nil
      if event_time.nil?
        log_time=Time.new.strftime(CEF::LOG_TIME_FORMAT)
      else
        log_time=event_time.strftime(CEF::LOG_TIME_FORMAT)
      end

      cef_message=CEF::PREFIX_FORMAT % [
        syslog_pri.to_s,
        my_hostname,
        log_time,
        format_prefix,
        format_extension
      ]
      cef_message
    end

    # used for non-schema fields
    def set_additional(k,v)
      @additional[k]=v
    end
    def get_additional(k,v)
      @additional[k]
    end

    private
      # make a guess as to how the time was set. parse strings and convert
      # them to epoch milliseconds, or leave it alone if it looks like a number
      # bigger than epoch milliseconds when i wrote this.
      def time_convert(val)
        converted=nil
        #puts "converting time for #{val.class.to_s}/#{val}"
        case val.class.to_s
          when "String"
            begin
              converted=val.to_i
            rescue
              res=ParseDate.parsedate(val)
              converted=Time.local(*res).to_i * 1000
            end
          when "Integer","Bignum"
            if val < 1232589621000 #Wed Jan 21 20:00:21 -0600 2009
              converted=val * 1000
            else
              converted=val
            end
          end
        converted
      end

      # escape only pipes and backslashes in the prefix. you bet your sweet
      # ass there's a lot of backslashes in the substitution. you can thank
      # the three levels of lexical analysis/substitution in the ruby interpreter
      # for that.
      def prefix_escape(val)
        val.gsub(/(\||\\)/,'\\\\\&')
      end

      # only equals signs need to be escaped in the extension. i think.
      # TODO: something in the spec about \n and some others.
      def extension_escape(val)
        val.gsub(/=/,'\=').gsub(/\n/,' ')
      end

      # returns a pipe-delimeted list of prefix attributes
      def format_prefix
        vendor=  self.deviceVendor       || "Breed"
        product= self.deviceProduct      || "CEF Sender"
        version= self.deviceVersion      || CEF::VERSION
        declid=  self.deviceEventClassId || "generic:0"
        name=    self.name               || "Generic Event"
        sev=     self.deviceSeverity     || "1"
        cef_prefix="%s|%s|%s|%s|%s|%s" % [
          prefix_escape(vendor),
          prefix_escape(product),
          prefix_escape(version),
          prefix_escape(declid),
          prefix_escape(name),
          prefix_escape(sev),
        ]
      end

      # returns a space-delimeted list of attribute=value pairs for all optionals
      def format_extension
        avpairs=[]
        CEF::EXTENSION_ATTRIBUTES.each do |attribute,shortname|
          unless self.send(attribute).nil?
            avpairs.push(
              "%s=%s" % [ shortname, extension_escape(self.send(attribute)) ]
            )
          end
        end

        # make sure time comes out as milliseconds since epoch
        CEF::TIME_ATTRIBUTES.each do |attribute,shortname|
          unless self.send(attribute).nil?
            avpairs.push(
              "%s=%s" % [ shortname, time_convert(self.send(attribute)) ]
            )
          end
        end
        avpairs.join(" ")
      end
    end
end