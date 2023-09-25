# frozen_string_literal: true

class CreateTerms < ActiveRecord::Migration[7.0]
  def change
    create_table :terms, id: :uuid do |t|
      t.references :glossary, null: false, foreign_key: true, type: :uuid
      t.string :source_term, null: false
      t.string :target_term, null: false

      t.timestamps
    end
  end
end
