# frozen_string_literal: true

json.extract! translation, :id, :source_text, :source_language_code, :target_language_code, :glossary_id

if translation.glossary_terms.any?
  json.glossary_terms translation.glossary_terms
  json.highlighted_source_text translation.highlighted_source_text
end
