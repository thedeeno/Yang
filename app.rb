require 'sinatra'
require 'i18n'
require 'i18n/backend/fallbacks'
require "sinatra/reloader" if development?

configure :development do
  enable :reloader
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
