# frozen_string_literal: true

class GlossariesController < ApplicationController
  include Authenticatable

  before_action :set_glossary, only: %i[show]

  attr_reader :glossaries, :glossary

  def index
    @glossaries = Glossary.all
    render :index, status: :ok
  end

  def show
    render :show, status: :ok
  end

  def create
    @glossary = Glossary.new(glossary_params)

    if glossary.save
      render :show, status: :created
    else
      @code = Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity]
      @resource = glossary
      render 'shared/messages', status: :unprocessable_entity
    end
  end

  private

  def set_glossary
    @glossary = Glossary.find(params[:id])
  rescue ActiveRecord::RecordNotFound => _e
    render 'shared/messages', status: :not_found
  end

  def glossary_params
    params.require(:glossary).permit(:source_language_code, :target_language_code)
  end
end
