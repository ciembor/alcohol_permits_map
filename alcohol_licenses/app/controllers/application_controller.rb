class ApplicationController < ActionController::Base
  before_action :set_locale

  def default_url_options
    return {} if I18n.locale == I18n.default_locale

    { locale: I18n.locale }
  end

  private

  def set_locale
    I18n.locale = requested_locale
  end

  def requested_locale
    locale = params[:locale].presence&.to_sym
    return locale if I18n.available_locales.include?(locale)

    I18n.default_locale
  end
end
