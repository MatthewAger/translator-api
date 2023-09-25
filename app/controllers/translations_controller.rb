# frozen_string_literal: true

class TranslationsController < ApplicationController
  include Authenticatable

  before_action :set_translation, only: %i[show]
  before_action :set_glossary, only: %i[create], if: -> { glossary_id.present? }

  attr_reader :translations, :translation

  def show
    render :show, status: :ok
  end

  def create
    @translation = Translation.new(translation_params)

    if translation.save
      render :show, status: :created
    else
      @code = Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity]
      @resource = translation
      render 'shared/messages', status: :unprocessable_entity
    end
  end

  private

  def set_translation
    @translation = Translation.find(params[:id])
  rescue ActiveRecord::RecordNotFound => _e
    render 'shared/messages', status: :not_found
  end

  def glossary_id
    params[:translation][:glossary_id]
  end

  def set_glossary
    @glossary = Glossary.find(glossary_id)
  rescue ActiveRecord::RecordNotFound => _e
    render 'shared/messages', status: :not_found
  end

  def translation_params
    params.require(:translation).permit(:source_language_code, :target_language_code, :source_text, :glossary_id)
  end
end
