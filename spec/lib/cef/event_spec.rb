require 'spec_helper'

describe CEF::Event do
  let(:formatted_time) { "Apr 25 1975 12:00:00" }
  let(:time)  { Chronic.parse(formatted_time) }
  
  context "formatting the syslog message" do
    let(:formatted) { "<131>Apr 25 1975 12:00:00 cefspec CEF:0|breed.org|CEF|#{CEF::VERSION}|0:event|unnamed event|1|" }
    let(:escaped)   { "<131>Apr 25 1975 12:00:00 cefspec CEF:0|bre\\|ed|CEF|#{CEF::VERSION}|0:event|unnamed event|1|" }
  end

  context "formatting the CEF prefix" do
    let(:formatted) {"breed.org|CEF|#{CEF::VERSION}|0:event|unnamed event|1"}
    let(:escaped)   {"bre\\|ed|CEF|#{CEF::VERSION}|0:event|unnamed event|1"}
    describe "#format_cef" do
      it "formats prefix values" do
        event=CEF::Event.new(
          event_time:         time,
          my_hostname:        "cefspec"
        )    
        expect(event.format_prefix).to eq(formatted)
      end
      it "escapes pipes in the prefix" do
        event=CEF::Event.new(
          event_time:         time,
          my_hostname:        "cefspec",
          deviceVendor:       "bre|ed"
        )    
        expect(event.format_prefix).to eq(escaped)
      end
    end
  end

  context 'formatting the CEF extension' do
    let(:escaped) { "suser=User\\=Name" }

    it 'escapes equal signs' do
      event = CEF::Event.new(
          sourceUserName: 'User=Name'
      )
      expect(event.format_extension).to eq(escaped)
    end
  end
end
