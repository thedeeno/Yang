require 'sinatra'
require 'i18n'
require 'i18n/backend/fallbacks'
require "sinatra/reloader" if development?

configure :development do
  enable :reloader
end

def accepted_locales(http_accept_language = request.env['HTTP_ACCEPT_LANGUAGE'])
  #
  # https://gist.github.com/naomik/5546046
  #
  return [] if http_accept_language.nil? || http_accept_language.empty?
  langs = http_accept_language.scan(/([a-zA-Z]{2,4})(?:-[a-zA-Z]{2})?(?:;q=(1|0?\.[0-9]{1,3}))?/).map do |pair|
    lang, q = pair
    [lang.to_sym, (q || '1').to_f]
  end
  langs.sort_by { |lang, q| q }.map { |lang, q| lang }.reverse
end

helpers do
  def content_tag(tag, content = nil, options = {})
    tag = tag.to_s
    html = "<#{tag}"
    options.each do |attribute, value|
      html << " #{attribute}=\"#{value}\""
    end
    html << (content ? ">#{content}</#{tag}>" : " />")
  end

  def youtube_iframe_embed(video_id:, **options)
    options = {
      enable_closed_captioning: true,
      use_http_accept_language: true,
      width: 560,
      height: 315,
      frameborder: 0,
      allow: "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture",
      allowfullscreen: true
    }.merge(options)

    uri = URI("https://www.youtube.com/embed/#{video_id}").tap { |uri|
      params = Hash.new.tap { |hash|
        hash[:cc_load_policy] = 1 if options.delete(:enable_closed_captioning)
        hash[:cc_lang_pref] = accepted_locales.first if options.delete(:use_http_accept_language) && accepted_locales.first
      }
      uri.query = URI.encode_www_form(params)
    }

    content_tag(:iframe, true, src: uri.to_s, **options)
  end
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
