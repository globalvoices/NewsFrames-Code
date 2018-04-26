class ProjectPresenter < Struct.new(:project, :current_pad_id)
  IMAGE_REGEX = /http.+((\.[pP][nN][gG])|(\.[jJ][pP][gG])|(\.[gG][iI][fF])|(\.[jJ][pP][eE][gG])|(\.[bB][mM][pP])|(\.[sS][vV][gG]))/

  def project_pads
    project.project_pads.order(:index)
  end

  def primary_pad
    project_pads.first
  end

  def current_pad
    @current_pad ||= if current_pad_id.present?
      project.project_pads.find(current_pad_id)
    else
      primary_pad
    end
  end

  def pad_list
    project_pads.map do |project_pad|
      OpenStruct.new(project_pad: project_pad, active: project_pad == current_pad)
    end
  end

  def checklist_count
    project.checklists.count
  end

  def pad_content
    pad = Etherpad::GetPad.(pad_id: current_pad.pad_id)

    # replace image links with img tags
    content = Nokogiri::HTML(pad.html)
    content.xpath('//a').each do |el|
      url = el.get_attribute('href')
      if url.match(IMAGE_REGEX)
        el.name = 'img'
        el.set_attribute('src', url)
        el.remove_attribute('href')
      end
    end

    content.to_html
  end
end
