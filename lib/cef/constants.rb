module CEF
    PREFIX_FORMAT="<%d>%s %s CEF:0|%s|%s"
  VERSION=File.read(File.join(File.expand_path(File.dirname(__FILE__)),'..','..','VERSION'))


  # CEF Dictionary
  # CEF Prefix attributes
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
end