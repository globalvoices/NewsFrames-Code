module ActiveAdmin::ViewsHelper
  include ApplicationHelper

  def available_languages_san_en
    available_languages.reject { |entry| entry == 'en_US' }
  end
end
