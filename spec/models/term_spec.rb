# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Term, type: :model do
  subject { build(:term) }

  it { should belong_to(:glossary) }

  it { should validate_presence_of(:source_term) }
  it { should validate_presence_of(:target_term) }
  it { should be_valid }

  describe 'database' do
    it {
      should have_db_column(:source_term)
        .of_type(:string)
        .with_options(null: false)
    }

    it {
      should have_db_column(:target_term)
        .of_type(:string)
        .with_options(null: false)
    }
  end
end
