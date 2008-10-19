module ApplicationHelper
  def current_page 
    params[:page].to_i < 1 ? 1 : params[:page].to_i 
  end

  def page_title
    @title = APP_NAME
  end

  def page_title=(title)
    @title ||= APP_NAME << " - #{title}"
  end

  def render_flashes
    flash.map do |type, value|
      content_tag('div', value, :id => "flash_#{type}")
    end.join("\n")
  end

end
