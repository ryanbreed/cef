require 'spec_helper'

describe CEF::UDPSender do
  it 'receives an escaped message when emit is called' do
    event = CEF::Event.new

    sock_double = double
    expect(UDPSocket).to receive(:new).and_return(sock_double)
    expect(sock_double).to receive(:connect).with('127.0.0.1', 514)
    expect(sock_double).to receive(:send).with(event.to_s, 0)

    sender = CEF::UDPSender.new
    sender.emit(event)
  end
end
