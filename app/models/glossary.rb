# frozen_string_literal: true

class Glossary < ApplicationRecord
  has_many :terms, inverse_of: :glossary, dependent: :destroy

  validates :source_language_code,
            presence: true,
            length: { is: 2 },
            inclusion: { in: Language.pluck(:code) },
            exclusion: { in: ->(g) { [g.target_language_code] } },
            uniqueness: { scope: :target_language_code }

  validates :target_language_code,
            presence: true,
            length: { is: 2 },
            inclusion: { in: Language.pluck(:code) },
            exclusion: { in: ->(g) { [g.source_language_code] } },
            uniqueness: { scope: :source_language_code }
end
