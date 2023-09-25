# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlossariesController, type: :request do
  let(:user) { create(:user) }
  let(:params) { { glossary: { source_language_code: 'en', target_language_code: 'mk' } } }
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
      get glossaries_path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is authenticated' do
    describe 'GET /glossaries' do
      before do
        create_list(:glossary, 3)
      end

      it 'returns a 200' do
        get glossaries_path, headers:, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.parsed_body).to be_an(Array)
        expect(response.parsed_body.size).to eq(3)
        expect(response.parsed_body.first).to have_key('id')
        expect(response.parsed_body.first).to have_key('source_language_code')
        expect(response.parsed_body.first).to have_key('target_language_code')
        expect(response.parsed_body.first).to have_key('terms')
        expect(response.parsed_body.first['terms']).to be_an(Array)
      end
    end

    describe 'GET /glossaries/:id' do
      let(:glossary) { create(:glossary) }

      it 'returns a 200' do
        get glossary_path(glossary), headers:, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.parsed_body).to be_a(Hash)
        expect(response.parsed_body).to have_key('id')
        expect(response.parsed_body).to have_key('source_language_code')
        expect(response.parsed_body).to have_key('target_language_code')
      end
    end

    describe 'POST /glossaries' do
      context 'when the request is valid' do
        it 'returns a 201' do
          post glossaries_path, params:, headers:, as: :json

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('id')
          expect(response.parsed_body).to have_key('source_language_code')
          expect(response.parsed_body).to have_key('target_language_code')
        end
      end

      context 'when the request is invalid' do
        let(:params) { { glossary: { source_language_code: 'en', target_language_code: 'en' } } }

        it 'returns a 422' do
          post glossaries_path, params:, headers:, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('code')
          expect(response.parsed_body['code']).to eq(422)
          expect(response.parsed_body).to have_key('error')
          expect(response.parsed_body['error']).to \
            eq('Source language code is reserved, Target language code is reserved')
        end
      end
    end

    context 'when a glossary has terms' do
      before do
        create(:glossary, :with_terms, terms_count: 3)
      end

      it 'returns a 200' do
        get glossaries_path, headers:, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.first['terms']).to be_an(Array)
        expect(response.parsed_body.first['terms'].size).to eq(3)
        expect(response.parsed_body.first['terms'].first).to have_key('id')
        expect(response.parsed_body.first['terms'].first).to have_key('source_term')
        expect(response.parsed_body.first['terms'].first).to have_key('target_term')
      end
    end
  end
end
