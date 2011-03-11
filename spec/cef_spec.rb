require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CEF Event Format" do
  it "should output a preamble" do
    prefix_vals=test_prefix_vals
    e=CEF::Event.new
    prefix_vals.each {|k,v| e.send("%s="%k,v) }
    formatted=CEF::PREFIX_FORMAT % [ 131, *prefix_vals.values ]
    
    e.format_cef==formatted
  end

end
