require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CEF Event Formatter" do
  describe "CEF Preamble" do
    it "should output a preamble" do
      prefix_vals=test_prefix_vals
      t=Time.new
      e=CEF::Event.new
      e.event_time=t
      prefix_vals.each {|k,v| e.send("%s="%k,v) }
      preformatted=CEF::PREFIX_FORMAT % [ 131, Socket.gethostname, t.strftime(CEF::LOG_TIME_FORMAT), test_prefix_string, ""]
      formatted=e.format_cef
      preformatted.should == formatted
    end
    it "should escape pipes in the prefix" do
      prefix_vals=test_prefix_escape_vals
      t=Time.new
      e=CEF::Event.new
      e.event_time=t
      prefix_vals.each {|k,v| e.send("%s="%k,v) }
      preformatted=CEF::PREFIX_FORMAT % [ 131, Socket.gethostname, t.strftime(CEF::LOG_TIME_FORMAT), test_prefix_escape_string, ""]
      formatted=e.format_cef
      preformatted.should == formatted
    end
  end
  describe "Cef Extension" do
    it "should output an extension"
    it "should escape newlines"
    it "should escape equal signs"
    it "should format time attributes"
  end
end

describe "UDPSender" do
  
end
