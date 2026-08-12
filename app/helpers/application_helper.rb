module ApplicationHelper
  def localized_url_for(locale)
    query = request.query_parameters.except('locale')
    query['locale'] = locale.to_s unless locale.to_sym == I18n.default_locale
    query_string = query.to_query

    public_path([request.path, query_string.presence].compact.join('?'))
  end

  def public_path(path)
    relative_root = Rails.application.config.relative_url_root.to_s.chomp('/')
    return path if relative_root.blank?
    return path if path == relative_root || path.start_with?("#{relative_root}/", "#{relative_root}?")

    "#{relative_root}#{path}"
  end

  def language_urls
    I18n.available_locales.each_with_object({}) do |locale, urls|
      urls[locale] = localized_url_for(locale)
    end
  end
end
