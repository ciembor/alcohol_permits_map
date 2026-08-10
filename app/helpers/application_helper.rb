module ApplicationHelper
  def localized_url_for(locale)
    query = request.query_parameters.except('locale')
    query['locale'] = locale.to_s unless locale.to_sym == I18n.default_locale
    query_string = query.to_query

    [request.path, query_string.presence].compact.join('?')
  end

  def language_urls
    I18n.available_locales.each_with_object({}) do |locale, urls|
      urls[locale] = localized_url_for(locale)
    end
  end
end
