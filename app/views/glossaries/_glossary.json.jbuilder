# frozen_string_literal: true

json.extract! glossary, :id, :source_language_code, :target_language_code

json.terms do
  json.array! glossary.terms, partial: 'glossaries/terms/term', as: :term
end
