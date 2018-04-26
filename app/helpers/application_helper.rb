module ApplicationHelper
  def to_bool(val)
    (!val.nil? && !(val.to_s.downcase.squish == 'false') && (val.to_s.downcase.squish == 'true' || val.to_s != '0' || val.to_s == '1'))
  end

  def available_languages
    @available_languages ||= ISO_639::ISO_639_2.map(&:alpha3)
  end

  def globalize(&block)
    Globalize.with_locale(ISO_639.find(I18n.locale.to_s).alpha3) do
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

