# frozen_string_literal: true

class Translation < ApplicationRecord
  WORD     = /\w+/
  NON_WORD = /\W+/
  TAG      = 'HIGHLIGHT'

  belongs_to :glossary, optional: true

  validates :source_text, presence: true, length: { maximum: 5_000 }

  validates :source_language_code,
            presence: true,
            length: { is: 2 },
            inclusion: { in: Language.pluck(:code) },
            exclusion: { in: ->(g) { [g.target_language_code] } }

  validates :target_language_code,
            presence: true,
            length: { is: 2 },
            inclusion: { in: Language.pluck(:code) },
            exclusion: { in: ->(g) { [g.source_language_code] } }

  validate :language_codes_match_glossary

  delegate :source_language_code, :target_language_code, to: :glossary, prefix: true, allow_nil: true

  def glossary_terms
    return [] if glossary.blank?

    source_words = source_text.split(NON_WORD).map(&:downcase)
    terms        = glossary.terms.where(source_term: source_words)
    terms.pluck(:source_term)
  end

  def highlighted_source_text
    return nil if glossary.blank?

    source_text.gsub(WORD) do |word|
      next word unless glossary_terms.include?(word.downcase)

      "<#{TAG}>#{word}</#{TAG}>"
    end
  end

  private

  def language_codes_match_glossary
    return unless glossary_source_language_code&.!=(source_language_code) &&
                  glossary_target_language_code&.!=(target_language_code)

    errors.add(:glossary, :invalid)
  end
end
