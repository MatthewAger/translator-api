# frozen_string_literal: true

class CreateGlossaries < ActiveRecord::Migration[7.0]
  def change
    create_table :glossaries, id: :uuid do |t|
      t.string :source_language_code, limit: 2, null: false
      t.string :target_language_code, limit: 2, null: false

      t.timestamps

      t.index %w[source_language_code target_language_code],
              unique: true,
              name: 'index_glossaries_on_source_and_target_language_codes'
    end
  end
end
