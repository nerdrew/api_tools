require 'spec_helper'

RSpec.describe APITools::RecordNotFound do
  describe 'initialize' do
    it 'only allows one attribute => value in the finder' do
      expect do
        described_class.new('why', Class.new, uuid: '4', name: 'bob')
      end.to raise_exception ArgumentError, 'only one finder pair allowed: {:uuid=>"4", :name=>"bob"}'
    end

    it 'raises an ArgumentError if the finder key is not a string or symbol' do
      expect do
        described_class.new('why', Class.new, 1 => '4')
      end.to raise_exception ArgumentError, 'finder key must respond to to_sym: 1'
    end
  end

  describe '#to_s' do
    it 'returns the argument string' do
      expect(APITools::RecordNotFound.new('why').to_s).to eq('why')
    end
  end
end
