module CEF
  require 'socket'
  require 'parsedate'
  PREFIX_FORMAT="<%d>%s %s CEF:0|%s|%s"


  
  # CEF Dictionary
  # CEF Prefix attributes
  # i know this is very dumb, but i am lazy
  PREFIX_ATTRIBUTES = {
    :deviceVendor       => "deviceVendor",
    :deviceVersion      => "deviceVersion", 
    :deviceProduct      => "deviceProduct", 
    :name               => "name", 
    :deviceSeverity     => "deviceSeverity", 
    :deviceEventClassId => "deviceEventClassId"
  }
 
  # these are the basic extension attributes. implementing others is as
  # simple as adding :symbolRepresentingMethodName => "cefkeyname", but
  # i am supremely lazy to type in the whole dictionary right now. perhaps
  # this should be a .yaml config file. Extension attributes are formatted
  # differently than core attributes.
  EXTENSION_ATTRIBUTES = { 
    :applicationProtocol          => "app",
    :baseEventCount               => "cnt",
    :bytesIn                      => "in",
    :bytesOut                     => "out",
    :deviceAction                 => "act",
    :deviceHostNam                => "dvc",
    :deviceNtDomain               => "deviceNtDomain",
    :deviceDnsDomain              => "deviceDnsDomain",
    :deviceTranslatedAddress      => "deviceTranslatedAddress",
    :deviceMacAddress             => "deviceMacAddress",
    :deviceCustomNumber1          => "cn1",
    :deviceCustomNumber2          => "cn2",
    :deviceCustomNumber3          => "cn3",
    :deviceCustomNumber1Label     => "cn1Label",
    :deviceCustomNumber2Label     => "cn2Label",
    :deviceCustomNumber3Label     => "cn3Label",
    :deviceCustomString1          => "cs1",
    :deviceCustomString2          => "cs2",
    :deviceCustomString3          => "cs3",
    :deviceCustomString4          => "cs4",
    :deviceCustomString5          => "cs5",
    :deviceCustomString6          => "cs6",
    :deviceCustomString1Label     => "cs1Label",
    :deviceCustomString2Label     => "cs2Label",
    :deviceCustomString3Label     => "cs3Label",
    :deviceCustomString4Label     => "cs4Label",
    :deviceCustomString5Label     => "cs5Label",
    :deviceCustomString6Label     => "cs6Label",
    :deviceCustomDate1            => "deviceCustomDate1",
    :deviceCustomDate2            => "deviceCustomDate2",
    :deviceCustomDate1Label       => "deviceCustomDate1Label",
    :deviceCustomDate2Label       => "deviceCustomDate2Label",
    :deviceEventCategory          => "cat",
    :destinationAddress           => "dst",
    :destinationDnsDomain         => "destinationDnsDomain",
    :destinationNtDomain          => "dntdom",
    :destinationHostName          => "dhost",
    :destinationMacAddress        => "dmac",
    :destinationPort              => "dpt",
    :destinationProcessName       => "dproc",
    :destinationServiceName       => "destinationServiceName",
    :destinationUserId            => "duid",
    :destinationUserPrivileges    => "dpriv",
    :destinationUserName          => "duser",
    :destinationTranslatedAddress => "destinationTranslatedAddress",
    :destinationTranslatedPort    => "destinationTranslatedPort",
    :deviceDirection              => "deviceDirection",
    :deviceExternalId             => "deviceExternalId",
    :deviceFacility               => "deviceFacility",
    :deviceInboundInterface       => "deviceInboundInterface",
    :deviceOutboundInterface      => "deviceOutboundInterface",
    :deviceProcessName            => "deviceProcessName",
    :externalId                   => "externalId",
    :fileHash                     => "fileHash",
    :fileId                       => "fileId",
    :fileName                     => "fname",
    :filePath                     => "filePath",
    :filePermission               => "filePermission",
    :fsize                        => "fsize",
    :fileType                     => "fileType",
    :message                      => "msg",
    :oldfileHash                  => "oldfileHash",
    :oldfileId                    => "oldfileId",
    :oldFilename                  => "oldFilename",
    :oldfilePath                  => "oldfilePath",
    :oldfilePermission            => "oldfilePermission",
    :oldfsize                     => "oldfsize",
    :oldfileType                  => "oldfileType",
    :requestURL                   => "request",
    :requestClientApplication     => "requestClientApplication",
    :requestCookies               => "requestCookies",
    :requestMethod                => "requestMethod",
    :sourceAddress                => "src",
    :sourceDnsDomain              => "sourceDnsDomain",
    :sourceHostName               => "shost",
    :sourceMacAddress             => "smac",
    :sourceNtDomain               => "sntdom",
    :sourcePort                   => "spt",
    :sourceServiceName            => "sourceServiceName",
    :sourceTranslatedAddress      => "sourceTranslatedAddress",
    :sourceTranslatedPort         => "sourceTranslatedPort",
    :sourceUserPrivileges         => "spriv",
    :sourceUserId                 => "suid",
    :sourceUserName               => "suser",
    :transportProtocol            => "proto"
  }

  # these are tracked separately so they can be normalized during formatting
  TIME_ATTRIBUTES={
    :fileCreateTime          => "fileCreateTime",
    :fileModificationTime    => "fileModificationTime",
    :oldfileCreateTime       => "oldfileCreateTime",
    :oldfileModificationTime => "oldfileModificationTime",
    :receiptTime             => "rt",
    :startTime               => "start",
    :endTime                 => "end"
  }

  ATTRIBUTES=PREFIX_ATTRIBUTES.merge EXTENSION_ATTRIBUTES.merge TIME_ATTRIBUTES

  # this class will formats and sends the cef event objects. you can use senders to set
  # default values for any event attribute, and you can send cef event objects to multiple
  # senders if you wish. 
  class Sender
    attr_accessor :receiver, :receiverPort, :eventDefaults
    attr_reader   :sock
  
    # you can pass in a hash of options to be run to set parameters
    def initialize(*params)
      p=Hash[*params]
      p.each {|k,v| self.send("#{k}=",v) }
      @sock=nil
    end
  
    def socksetup
      @sock=UDPSocket.new
      receiver= self.receiver || "loghost"
      port= self.receiverPort || 514
      @sock.connect(receiver,port)
    end
  
    # formats a CEFEvent 
    def format_event( event )
      #HELL yeah it's hard-coded. What are you going to do about it?
      #syslog_pri= Syslog::LOG_LOCAL0 | Syslog::LOG_NOTICE
      syslog_pri=131
  
      # process eventDefaults - we are expecting a hash here. These will 
      # override any values in the events passed to us. i know. brutal.
      unless self.eventDefaults.nil?
        self.eventDefaults.each do |k,v|
	  event.send("#{k}=",v)
        end
      end
      cef_message=PREFIX_FORMAT % [
        syslog_pri, 
        Socket::gethostname,
	Time.new.strftime("%b %d %Y %H:%M:%S"),
        event.prefix,
        event.extension
      ]
      cef_message
    end
  
    #fire the message off
    def emit(event)
      self.socksetup if self.sock.nil?
      self.sock.send self.format_event(event), 0
    end
  end
  
  class Event
    #%#
    # set up accessors for all of the event attributes. ruby meta magic.
    ATTRIBUTES.each do |k,v|
      self.instance_eval do
        attr_accessor k
      end
    end

    def attrs
      ATTRIBUTES
    end
  
    # so we can CEFEvent.new(:foo=>"bar")
    def initialize( *params )
      p=Hash[*params]
      p.each { |k,v| self.send("#{k}=",v) }
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
      val.gsub(/=/,'\=')
    end
  
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
  
    # returns a pipe-delimeted list of prefix attributes
    def prefix
      vendor=  self.deviceVendor       || "Breed"
      product= self.deviceProduct      || "CEF Sender"
      version= self.deviceVersion      || "0.4"
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
    def extension
      avpairs=[]
      EXTENSION_ATTRIBUTES.each do |attribute,shortname|
        unless self.send(attribute).nil?
          avpairs.push( 
            "%s=%s" % [ shortname, extension_escape(self.send(attribute)) ]
          )
        end
      end
  
      # make sure time comes out as milliseconds since epoch
      TIME_ATTRIBUTES.each do |attribute,shortname|
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


