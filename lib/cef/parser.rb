# COPYRIGHT: Ryan Breed
# DATE:      3/27/11
module CEF
  class Parser
    # TODO: deal with escaping delimeters
    
    attr_accessor :file_name

    def initialize(*args)
      # Parser.new(:foo=>"bar)
      Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }
      
      yield self if block_given?
    end

    def parse_file
      events=[]
      File.open(file_name) do |f|
        f.each_line do |line|
          line.chomp!
          prefix=line.split(/\|/)
          e=Event.new
          extension_string=prefix[7..-1].join("|")
          extension_av_pairs=extension_string.split(/ ([\w\.]+)=/)
          extension_av_pairs.shift


          begin
            extension=Hash[ *extension_av_pairs.map {|i| i.strip} ]
            extension.each do |k,v|
              next if k.match(/^ad\./)
              methname=CEF::ATTRIBUTES.invert[k].to_s
              #puts "METHNAME: #{k} -> #{methname}"
              e.send("%s=" % methname, v)
            end

          rescue Exception => except
            puts except.message
            pp   extension_av_pairs
            puts line
            next
          end

          %w{ deviceVendor deviceProduct deviceVersion
              deviceEventClassId name deviceSeverity }.each_with_index {|att,i| e.send("%s="%att,prefix[i+1]) }

          if block_given?
            yield e
          else
            events.push e
          end

        end
      end
      events
    end
  end
end
