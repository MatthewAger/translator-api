# frozen_string_literal: true

Rails.application.routes.draw do
  resources :translations, only: %i[create show], defaults: { format: :json }

  resources :glossaries, only: %i[index show create], defaults: { format: :json } do
    member do
      resources :terms, only: :create, defaults: { format: :json }, controller: 'glossaries/terms'
    end
  end

  devise_for :users, defaults: { format: :json }
end
