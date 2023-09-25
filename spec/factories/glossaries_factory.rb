# frozen_string_literal: true

FactoryBot.define do
  factory :glossary do
    sequence(:source_language_code) { |i| Language.find(i).code }
    sequence(:target_language_code) { |i| Language.find(i + 1).code }

    trait :with_terms do
      transient do
        terms_count { 1 }
      end

      after(:create) do |glossary, evaluator|
        create_list(:term, evaluator.terms_count, glossary:)
      end
    end
  end
end
