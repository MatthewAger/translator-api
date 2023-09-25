# frozen_string_literal: true

require 'devise/jwt/test_helpers'

User.destroy_all
user            = User.create! email: 'user@example.com'
token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
puts "Created user with email: #{user.email}"
puts 'Make authenticated requests as this user by passing an appropriate JWT. For example:'
puts <<~CURL
  curl -X POST \\
       -H "Accept: application/json" \\
       -H "Content-Type: application/json" \\
       -H "Authorization: Bearer #{token}" \\
       -d '{"glossary": { "source_language_code": "en", "target_language_code": "de" } }' \\
       localhost:3000/glossaries
CURL
puts 'and'
puts <<~CURL
  curl -X GET \\
       -H "Accept: application/json" \\
       -H "Content-Type: application/json" \\
       -H "Authorization: Bearer #{token}" \\
       localhost:3000/glossaries
CURL
