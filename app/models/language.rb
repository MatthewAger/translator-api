# frozen_string_literal: true

require 'csv'

class Language < ActiveFile::Base
  set_root_path Rails.root.join('config/locales')
  set_filename 'language-codes'

  class << self
    def extension
      'csv'
    end

    def load_file
      csv = CSV.read(full_path, headers: true)
      csv.map.with_index do |row, index|
        row.to_h.merge(id: index + 1)
      end
    end
  end
end
