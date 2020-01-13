require 'sinatra'
require 'i18n'
require 'i18n/backend/fallbacks'

def accepted_locales(http_accept_language = request.env['HTTP_ACCEPT_LANGUAGE'])
  #
  # https://gist.github.com/naomik/5546046
  #
  return [] if http_accept_language.empty?
  langs = http_accept_language.scan(/([a-zA-Z]{2,4})(?:-[a-zA-Z]{2})?(?:;q=(1|0?\.[0-9]{1,3}))?/).map do |pair|
    lang, q = pair
    [lang.to_sym, (q || '1').to_f]
  end
  langs.sort_by { |lang, q| q }.map { |lang, q| lang }.reverse
end

configure do
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path += Dir[File.join(settings.root, 'locales', '*.yml')]
  I18n.backend.load_translations
end

before "/:locale*" do
  locale = params[:locale].to_sym
  halt 404 unless I18n.available_locales.include?(locale)
  I18n.locale = locale
  request.path_info = '/' + params[:splat ][0]
end

get '/' do
  erb :index
end
