require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CEF Event Format" do
  it "should output a preamble" do
    test_prefix_vals={
      :deviceVendor       => "breed",
      :deviceProduct      => "CEF Sender",
      :deviceVersion      => "0.1",
      :deviceEventClassId => "0:debug",
      :name               => "test",
      :deviceSeverity     => "1"
    }
    e=CEF::Event.new
    test_prefix_vals.each {|k,v| e.send("%s="%k,v) }
    s=CEF::Sender.new
    formatted=CEF::PREFIX_FORMAT % [ 131, *test_prefix_vals.values ]
    s.format_event(e) ==formatted
  end
end
