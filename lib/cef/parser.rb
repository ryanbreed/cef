# COPYRIGHT: Ryan Breed
# DATE:      3/27/11
class Parser
  # attr_accessor :foo

  def initialize(*args)
    # Parser.new(:foo=>"bar)
    Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }


    yield self if block_given?
  end
end