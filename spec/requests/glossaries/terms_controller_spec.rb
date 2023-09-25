# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Glossaries::TermsController, type: :request do
  let(:glossary) { create(:glossary) }
  let(:user) { create(:user) }
  let(:uuid) { SecureRandom.uuid }
  let(:params) { { term: { source_term: 'hello', target_term: 'hola' } } }
  let(:headers) do
    Devise::JWT::TestHelpers.auth_headers(
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      },
      user
    )
  end

  context 'when the user is not authenticated' do
    it 'returns a 401' do
      post terms_path(glossary), params:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is authenticated' do
    describe 'POST /glossaries/:id/terms' do
      context 'when the request is valid' do
        it 'returns a 201' do
          post terms_path(glossary), params:, headers:, as: :json

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('id')
          expect(response.parsed_body).to have_key('source_term')
          expect(response.parsed_body).to have_key('target_term')
        end
      end

      context 'when the glossary does not exist' do
        it 'returns a 404' do
          post terms_path(uuid), params:, headers:, as: :json

          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('code')
          expect(response.parsed_body['code']).to eq(404)
          expect(response.parsed_body).to have_key('error')
          expect(response.parsed_body['error']).to eq('Not Found')
        end
      end

      context 'when the request is invalid' do
        let(:params) { { term: { source_term: '', target_term: '' } } }

        it 'returns a 422' do
          post terms_path(glossary), params:, headers:, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('code')
          expect(response.parsed_body['code']).to eq(422)
          expect(response.parsed_body).to have_key('error')
          expect(response.parsed_body['error']).to \
            eq("Source term can't be blank, Target term can't be blank")
        end
      end
    end
  end
end
