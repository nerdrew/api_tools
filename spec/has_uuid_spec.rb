require 'spec_helper'

RSpec.describe APITools::HasUuid do
  build_model :elegant_german_beer_stein do
    extend APITools::HasUuid
    string :uuid, limit: 36, null: false, default: ""
    boolean :foo

    has_uuid
  end

  subject { ElegantGermanBeerStein.new }
  let(:described_class) { ElegantGermanBeerStein }
  it_behaves_like 'has_uuid'
end
