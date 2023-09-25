# frozen_string_literal: true

class CreateTranslations < ActiveRecord::Migration[7.0]
  def change
    create_table :translations, id: :uuid do |t|
      t.references :glossary, null: true, foreign_key: true, type: :uuid
      t.string :source_language_code, null: false, limit: 2
      t.string :target_language_code, null: false, limit: 2
      t.text :source_text, null: false

      t.timestamps
    end
  end
end
