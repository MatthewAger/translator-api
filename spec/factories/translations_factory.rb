# frozen_string_literal: true

FactoryBot.define do
  factory :translation do
    source_text          { 'Hello world!' }
    source_language_code { 'en' }

    sequence(:target_language_code) { |i| Language.find(i).code }

    glossary { nil } # optional
  end
end
