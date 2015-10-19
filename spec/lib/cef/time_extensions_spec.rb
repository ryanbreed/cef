require 'spec_helper'
describe CEF::TimeExtensions do
  context 'coercing time values' do
    let(:bday) { 166813200 }
    let(:tm) { Time.at(bday)}
    describe '.coerce' do
      it 'parses string %Y/%m/%d %H:%M:%S' do
        expect(Time.coerce('1975/04/15 12:00:00')).to eq(tm)
      end
      it 'casts integers into Time values' do
        expect(Time.coerce(bday)).to eq(tm)
      end
      it 'passes Time values through' do
        expect(Time.coerce(Time.at(bday))).to eq(tm)
      end
      it 'passes everything else through' do
        expect(Time.coerce(:nope)).to eq(:nope)
      end
    end
  end
end
