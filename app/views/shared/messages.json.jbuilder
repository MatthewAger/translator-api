# frozen_string_literal: true

json.code @code || Rack::Utils::SYMBOL_TO_STATUS_CODE[:not_found]
json.error @resource&.errors&.full_messages&.join(', ') || 'Not Found'
