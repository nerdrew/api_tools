require 'spec_helper'
require 'action_controller'

RSpec.describe APITools::StrongerParameters do
  klass = Class.new(ActionController::Parameters) { include APITools::StrongerParameters }
  let(:hash) { klass.new }

  before(:all) do
    APITools.logger.level = Logger::ERROR
  end

  describe '#lint' do
    it 'does not raise if there are no missing, unpermitted, or type mismatches' do
      hash['foo'] = 2
      hash['boo'] = 'goat'
      expect { hash.lint(foo!: Integer, boo: String) }.not_to raise_exception
    end

    it 'sets permitted for valid params' do
      hash['boo'] = 'goat'
      expect(hash.permitted?).to be_falsey
      expect(hash.lint(boo: String).permitted?).to be(true)
    end

    it 'raises if there is a missing required param' do
      hash['boo'] = 'goat'
      expect { hash.lint(foo!: String) }.to raise_exception(APITools::StrongerParameters::Error)
    end

    context 'type mismatch' do
      it 'raises if there is a type mismatch' do
        hash['foo'] = 'bam'
        expect { hash.lint(foo: Integer) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'uses TrueClass || FalseClass for bools' do
        hash['foo'] = 'bam'
        expect { hash.lint(foo: TrueClass) }.to raise_exception(APITools::StrongerParameters::Error)
        hash['foo'] = true
        expect { hash.lint(foo: TrueClass) }.not_to raise_exception
        expect { hash.lint(foo: FalseClass) }.not_to raise_exception
        hash['foo'] = false
        expect { hash.lint(foo: TrueClass) }.not_to raise_exception
        expect { hash.lint(foo: FalseClass) }.not_to raise_exception
      end
    end

    it 'strips unpermitted params' do
      hash['foo'] = 'bam'
      hash['boo'] = 'gah'
      expect(hash.lint(boo: String)).to eq('boo' => 'gah')
    end

    context 'with arrays' do
      it 'works with arrays of a type' do
        hash['foo'] = ['cat', 'dog']
        expect(hash.lint(foo: [String])).to eq('foo' => ['cat', 'dog'])
      end

      it 'raises if there is a type mismatch in an array' do
        hash['foo'] = ['cat', 'dog']
        expect { hash.lint(foo: [Integer]) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'raises if there is an array mismatch' do
        hash['foo'] = ['cat', 'dog']
        expect { hash.lint(foo: String) }.to raise_exception(APITools::StrongerParameters::Error)
        hash['foo'] = 'cat'
        expect { hash.lint(foo: [String]) }.to raise_exception(APITools::StrongerParameters::Error)
      end
    end

    context 'with an array of nested params' do
      it 'works' do
        nested1 = klass.new
        nested1['bam'] = 'cat'
        nested2 = klass.new
        nested2['bam'] = 'dog'
        hash['foo'] = [nested1, nested2]
        expect(hash.lint(foo: [{bam: String}])).to eq('foo' => [{'bam' => 'cat'}, {'bam' => 'dog'}])
      end
    end

    context 'with nested params' do
      before do
        nested = klass.new
        nested['bam'] = 2
        hash['foo'] = nested
      end

      it 'works' do
        expect(hash.lint(foo: {bam: Integer})).to eq('foo' => {'bam' => 2})
      end

      it 'checks types in the nested hash' do
        expect { hash.lint(foo: {bam: String}) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'checks missing params in the nested hash' do
        expect { hash.lint(foo: {req!: String}) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'strips unpermitted params in the nested hash' do
        expect(hash.lint(foo: {goat: Integer})).to eq('foo' => {})
      end

      it 'checks missing params in the parent hash' do
        expect { hash.lint(bam!: {bam: Integer}) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'strips unpermitted params in the parent hash' do
        expect(hash.lint(bam: {bam: Integer})).to eq({})
      end
    end

    context 'type is Date' do
      it 'raises if the date is not in YYYY-MM-DD format' do
        hash['date'] = 'July 25, 2014'
        expect { hash.lint(date: Date) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'converts dates in YYYY-MM-DD format to Date' do
        hash['date'] = '2014-07-14'
        expect(hash.lint(date: Date)).to eq('date' => Date.new(2014, 7, 14))
      end
    end

    context 'type is Time' do
      it 'raises if the time is not in YYYY-MM-DDTHH:MM:SSZ format' do
        hash['time'] = 'July 25, 2014, 12:34:56'
        expect { hash.lint(time: Time) }.to raise_exception(APITools::StrongerParameters::Error)
      end

      it 'converts dates in YYYY-MM-DD format to Date' do
        hash['time'] = '2014-07-14T13:45:26Z'
        expect(hash.lint(time: Time)).to eq('time' => Time.utc(2014, 7, 14, 13, 45, 26))
      end
    end
  end

  describe "#lint!" do
    it 'raises if there is an unpermitted param' do
      hash['boo'] = 'goat'
      expect { hash.lint!(foo: String) }.to raise_exception(APITools::StrongerParameters::Error)
    end

    it 'sets permitted for valid params' do
      hash['boo'] = 'goat'
      expect(hash.permitted?).to be_falsey
      expect(hash.lint!(boo: String).permitted?).to be(true)
    end
  end
end
