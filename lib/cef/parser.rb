# COPYRIGHT: Ryan Breed
# DATE:      3/27/11
module CEF
  class Parser
    attr_accessor :file_name

    def initialize(*args)
      # Parser.new(:foo=>"bar)
      Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }
      yield self if block_given?
    end
    def parse_file
      File.open(file_name) do |f|
        f.each_line do |line|
          line.chomp!
          prefix=line.split(/[^\\]\|/).map {|i| i.strip}
          extension=Hash[ *prefix_components[-1].split(/([\w]+)=/).select {|i| i!=""}.map {|i| i.strip} ]
          
        end
      end
    end

  end
end
