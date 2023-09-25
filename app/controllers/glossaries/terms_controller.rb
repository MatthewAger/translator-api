# frozen_string_literal: true

module Glossaries
  class TermsController < ApplicationController
    include Authenticatable

    before_action :set_glossary

    attr_reader :glossary, :term

    def create
      @term = glossary.terms.new(term_params)

      if term.save
        render :show, status: :created
      else
        @code = Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity]
        @resource = term
        render 'shared/messages', status: :unprocessable_entity
      end
    end

    private

    def set_glossary
      @glossary = Glossary.find(params[:id])
    rescue ActiveRecord::RecordNotFound => _e
      render 'shared/messages', status: :not_found
    end

    def term_params
      params.require(:term).permit(:source_term, :target_term)
    end
  end
end
