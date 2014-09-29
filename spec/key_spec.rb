require 'spec_helper'

RSpec.describe APITools::Key do
  describe '#name' do
    it 'returns the name' do
      expect(described_class.parse('bam!').name).to eq('bam')
    end

    it 'returns the name with ! if escaped' do
      expect(described_class.parse('bam\!').name).to eq('bam!')
    end
  end

  describe '#required?' do
    it 'returns true if the field is required' do
      expect(described_class.parse('bam!').required?).to eq(true)
    end

    it 'returns false if it is not required' do
      expect(described_class.parse('bam\!').required?).to eq(false)
    end
  end

  describe '#extended_name' do
    it 'returns the name with (required) if required' do
      expect(described_class.parse('bam!').extended_name).to eq('bam (required)')
    end

    it 'returns the name if not required' do
      expect(described_class.parse('bam').extended_name).to eq('bam')
    end
  end
end
