$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'cef'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

def test_prefix_vals
  test_prefix_vals={
    :deviceVendor       => "breed",
    :deviceProduct      => "CEF Sender",
    :deviceVersion      => "0.1",
    :deviceEventClassId => "0:debug",
    :name               => "test",
    :deviceSeverity     => "1"
  }
end

def test_prefix_escape_vals
  test_prefix_escape_vals={
    :deviceVendor       => "bre|ed",
    :deviceProduct      => "CEF Sender",
    :deviceVersion      => "0.1",
    :deviceEventClassId => "0:debug",
    :name               => "test",
    :deviceSeverity     => "1"
  }
end

def test_extension_vals
  test_extension_vals={
      :sourceAddress      => "192.168.1.1",
      :destinationAddress => "192.168.1.2"
  }
end

def test_prefix_string
  "breed|CEF Sender|0.1|0:debug|test|1"
end