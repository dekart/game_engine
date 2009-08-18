class Admin::TranslationsController < ApplicationController
  before_filter :admin_required

  def index
    I18n.backend.send(:init_translations)
    
    @translations = translations_to_array(I18n.backend.send(:translations)[I18n.locale])
    @translations.sort!
  end

  def new
    if @translation = Translation.find_by_key(params[:key])
      redirect_to [:edit, :admin, @translation]
    else
      @translation = Translation.new(:key => params[:key])
    end
  end

  def create
    @translation = Translation.new(params[:translation])

    if @translation.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @translation = Translation.find(params[:id])
  end

  def update
    @translation = Translation.find(params[:id])

    if @translation.update_attributes(params[:translation])
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  protected

  def translations_to_array(translations, prefix = nil)
    result = translations.inject([]) do |result, (key, value)|
      if value.is_a?(Hash)
        items = translations_to_array(value, key)
      elsif value.is_a?(String)
        items = [[key, value]]
      else
        items = []
      end
      
      items.each do |k, v|
        result << [[prefix, k].compact.join("."), v]
      end

      result
    end

    result
  end
end
