class Admin::TranslationsController < Admin::BaseController
  def index
    I18n.backend.send(:init_translations)

    @translations = translations_to_array(I18n.backend.send(:translations)[I18n.locale])
    @translations.sort!

    @customizations = Translation.all(:order => "translations.key")

    @translations.reject!{|key, value| key.starts_with?("admin") }

    @translations.collect!{|key, value|
      [key, value, @customizations.find{|c| c.key == key }]
    }
  end

  def new
    @translation = Translation.new(:key => params[:key])

    I18n.backend.send(:init_translations)

    @current_value = translations_to_array(I18n.backend.send(:translations)[I18n.locale]).assoc(params[:key]).last
  end

  def create
    @translation = Translation.new(params[:translation])

    if @translation.save
      render :action => :show
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
      render :action => :show
    else
      render :action => :edit
    end
  end

  def destroy
    @translation = Translation.find(params[:id])

    @translation.destroy
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
