# frozen_string_literal: true

class Term < ApplicationRecord
  belongs_to :glossary, inverse_of: :terms

  validates :source_term, presence: true
  validates :target_term, presence: true
end
