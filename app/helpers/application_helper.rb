module ApplicationHelper
  def to_bool(val)
    (!val.nil? && !(val.to_s.downcase.squish == 'false') && (val.to_s.downcase.squish == 'true' || val.to_s != '0' || val.to_s == '1'))
  end

  def available_languages
    LANGUAGES.map(&:last)
  end

  def globalize(&block)
    Globalize.with_locale(I18n.locale.to_s) do
      block.call
    end
  end

  def nav_link(link_path, options = {})
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_path, options do
        yield
      end
    end
  end
end
