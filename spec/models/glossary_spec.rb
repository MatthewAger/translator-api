# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Glossary, type: :model do
  subject { build(:glossary) }

  it { should have_many(:terms) }

  it { should validate_presence_of(:source_language_code) }
  it { should validate_presence_of(:target_language_code) }
  it { should validate_length_of(:source_language_code).is_equal_to(2) }
  it { should validate_length_of(:target_language_code).is_equal_to(2) }
  it { should validate_uniqueness_of(:source_language_code).scoped_to(:target_language_code) }
  it { should validate_uniqueness_of(:target_language_code).scoped_to(:source_language_code) }
  it { should validate_inclusion_of(:source_language_code).in_array(Language.pluck(:code)) }
  it { should validate_inclusion_of(:target_language_code).in_array(Language.pluck(:code)) }
  it { should validate_exclusion_of(:source_language_code).in_array([subject.target_language_code]) }
  it { should validate_exclusion_of(:target_language_code).in_array([subject.source_language_code]) }
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
  end
end
