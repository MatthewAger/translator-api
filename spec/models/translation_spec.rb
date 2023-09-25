# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Translation, type: :model do
  subject { build(:translation) }

  it { should belong_to(:glossary).optional }

  it { should validate_presence_of(:source_language_code) }
  it { should validate_presence_of(:target_language_code) }
  it { should validate_presence_of(:source_text) }
  it { should validate_length_of(:source_language_code).is_equal_to(2) }
  it { should validate_length_of(:target_language_code).is_equal_to(2) }
  it { should validate_inclusion_of(:source_language_code).in_array(Language.pluck(:code)) }
  it { should validate_inclusion_of(:target_language_code).in_array(Language.pluck(:code)) }
  it { should validate_exclusion_of(:source_language_code).in_array([subject.target_language_code]) }
  it { should validate_exclusion_of(:target_language_code).in_array([subject.source_language_code]) }
  it { should validate_length_of(:source_text).is_at_most(5_000) }

  it { should be_valid }

  describe 'database' do
    it {
      should have_db_column(:source_language_code)
        .of_type(:string)
        .with_options(limit: 2, null: false)
    }

    it {
      should have_db_column(:target_language_code)
        .of_type(:string)
        .with_options(limit: 2, null: false)
    }

    it {
      should have_db_column(:source_text)
        .of_type(:text)
        .with_options(null: false)
    }

    it {
      should have_db_column(:glossary_id)
        .of_type(:uuid)
        .with_options(null: true)
    }
  end

  describe '#glossary_terms' do
    let(:glossary) { create(:glossary, source_language_code: 'en', target_language_code: 'mk') }
    let(:translation) do
      create(
        :translation,
        glossary:,
        source_text: 'Hello world!',
        source_language_code: 'en',
        target_language_code: 'mk'
      )
    end

    it 'returns terms from the glossary' do
      create(:term, glossary:, source_term: 'hello', target_term: 'здраво')
      expect(translation.glossary_terms).to eq(['hello'])
    end
  end

  describe '#highlighted_source_text' do
    let(:glossary) { create(:glossary, source_language_code: 'en', target_language_code: 'mk') }
    let(:translation) do
      create(
        :translation,
        glossary:,
        source_text: 'Hello world!',
        source_language_code: 'en',
        target_language_code: 'mk'
      )
    end

    it 'returns the source text with highlighted terms' do
      create(:term, glossary:, source_term: 'hello', target_term: 'здраво')
      expect(translation.highlighted_source_text).to eq('<HIGHLIGHT>Hello</HIGHLIGHT> world!')
    end
  end
end
