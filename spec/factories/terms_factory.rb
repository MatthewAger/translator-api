# frozen_string_literal: true

FactoryBot.define do
  factory :term do
    glossary { build(:glossary, source_language_code: 'en', target_language_code: 'mk') }

    source_term { 'hello' }
    target_term { 'здраво' }
  end
end
