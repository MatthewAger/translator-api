# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationsController, type: :request do
  let(:user) { create(:user) }

  let(:params) do
    {
      translation: {
        source_language_code: 'en',
        target_language_code: 'mk',
        source_text: 'Hello world!'
      }
    }
  end

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
    describe 'GET /translations/:id' do
      context 'when the translation exists' do
        context 'when the translation does not belong to a glossary' do
          let(:translation) { create(:translation, source_text: 'Hello world!', source_language_code: 'en') }

          it 'returns a 200' do
            get translation_path(translation), headers:, as: :json

            expect(response).to have_http_status(:ok)
            expect(response.content_type).to eq('application/json; charset=utf-8')
            expect(response.parsed_body).to be_a(Hash)
            expect(response.parsed_body).to have_key('id')
            expect(response.parsed_body).to have_key('source_language_code')
            expect(response.parsed_body).to have_key('target_language_code')
            expect(response.parsed_body).to have_key('source_text')
            expect(response.parsed_body['source_text']).to eq('Hello world!')
            expect(response.parsed_body).to have_key('glossary_id')
            expect(response.parsed_body['glossary_id']).to be_nil
          end
        end

        context 'when the translation belongs to a glossary' do
          let(:glossary) { create(:glossary, source_language_code: 'en') }
          let(:translation) do
            create(
              :translation,
              glossary:,
              source_text: 'Hello world!',
              source_language_code: glossary.source_language_code,
              target_language_code: glossary.target_language_code
            )
          end

          it 'returns a 200 and includes a glossary_id' do
            get translation_path(translation), headers:, as: :json

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body['glossary_id']).to eq(translation.glossary.id)
          end
        end

        context 'when the translation belongs to a glossary which has terms' do
          let(:glossary) { create(:glossary, source_language_code: 'en', target_language_code: 'mk') }
          let(:translation) do
            create(
              :translation,
              glossary:,
              source_text: 'Hello world!',
              source_language_code: 'en',
              target_language_code: 'mk'
            )
          end

          it 'returns a 200 and includes terms and highlights' do
            create(:term, glossary:, source_term: 'hello', target_term: 'здраво')
            get translation_path(translation), headers:, as: :json

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to have_key('glossary_terms')
            expect(response.parsed_body['glossary_terms']).to be_an(Array)
            expect(response.parsed_body['glossary_terms'].size).to eq(1)
            expect(response.parsed_body['glossary_terms'].first).to eq('hello')
            expect(response.parsed_body).to have_key('highlighted_source_text')
            expect(response.parsed_body['highlighted_source_text']).to eq('<HIGHLIGHT>Hello</HIGHLIGHT> world!')
          end
        end
      end

      context 'when the translation does not exist' do
        it 'returns a 404' do
          get translation_path(SecureRandom.uuid), headers:, as: :json

          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response.parsed_body).to be_a(Hash)
          expect(response.parsed_body).to have_key('error')
          expect(response.parsed_body['error']).to eq('Not Found')
        end
      end
    end

    describe 'POST /translations' do
      context 'when the request is valid' do
        context 'when glossary is not provided' do
          it 'returns a 201' do
            post translations_path, params:, headers:, as: :json

            expect(response).to have_http_status(:created)
            expect(response.content_type).to eq('application/json; charset=utf-8')
            expect(response.parsed_body).to be_a(Hash)
            expect(response.parsed_body).to have_key('id')
            expect(response.parsed_body).to have_key('source_language_code')
            expect(response.parsed_body).to have_key('target_language_code')
            expect(response.parsed_body).to have_key('source_text')
            expect(response.parsed_body).to have_key('glossary_id')
          end
        end

        context 'when a valid glossary is provided' do
          let(:glossary) { create(:glossary, source_language_code: 'en', target_language_code: 'mk') }
          let(:params) do
            {
              translation: {
                source_language_code: 'en',
                target_language_code: 'mk',
                source_text: 'Hello world!',
                glossary_id: glossary.id
              }
            }
          end

          it 'returns a 201' do
            post translations_path, params:, headers:, as: :json

            expect(response).to have_http_status(:created)
            expect(response.parsed_body['glossary_id']).to eq(glossary.id)
          end
        end
      end

      context 'when the request is invalid' do
        context 'when a valid glossary is provided' do
          let(:glossary) { create(:glossary, source_language_code: 'en', target_language_code: 'mk') }
          let(:params) do
            {
              translation: {
                source_language_code: 'en',
                target_language_code: 'mk',
                source_text: '',
                glossary_id: glossary.id
              }
            }
          end

          it 'returns a 422' do
            post translations_path, params:, headers:, as: :json

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq('application/json; charset=utf-8')
            expect(response.parsed_body).to be_a(Hash)
            expect(response.parsed_body).to have_key('code')
            expect(response.parsed_body['code']).to eq(422)
            expect(response.parsed_body).to have_key('error')
            expect(response.parsed_body['error']).to \
              eq("Source text can't be blank")
          end
        end

        context 'when an invalid glossary is provided' do
          let(:params) do
            {
              translation: {
                source_language_code: 'en',
                target_language_code: 'mk',
                source_text: 'Hello world!',
                glossary_id: SecureRandom.uuid
              }
            }
          end

          it 'returns a 422' do
            post translations_path, params:, headers:, as: :json

            expect(response).to have_http_status(:not_found)
            expect(response.content_type).to eq('application/json; charset=utf-8')
            expect(response.parsed_body).to be_a(Hash)
            expect(response.parsed_body).to have_key('code')
            expect(response.parsed_body['code']).to eq(404)
            expect(response.parsed_body).to have_key('error')
            expect(response.parsed_body['error']).to eq('Not Found')
          end
        end
      end
    end
  end
end
