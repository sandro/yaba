require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe 'Flashes' do
    it 'should render a flash type' do
      flash[:notice] = "notice"
      flash[:error] = "error"
      flash.each do |type, message|
        helper.render_flashes.should have_tag("div#flash_#{type}", message)
      end
    end

    it 'should render many flash types simultanously' do
      flash[:notice] = "notice"
      flash[:error] = "error"
      elements_displayed = helper.render_flashes
      elements_displayed.should have_tag("div#flash_notice")
      elements_displayed.should have_tag("div#flash_error")
    end

    it 'should not render when no flash is set' do
      helper.render_flashes.should be_blank
    end
  end

  describe 'page_title' do
    it 'should render the default page title' do
      helper.page_title.should include(APP_NAME)
    end

    it 'should render the default page title with an additional title' do
      helper.page_title = "A secondary page"
      helper.page_title.should include(APP_NAME, 'secondary')
    end
  end
end
