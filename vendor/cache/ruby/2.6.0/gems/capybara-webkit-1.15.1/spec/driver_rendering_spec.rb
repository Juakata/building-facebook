require 'spec_helper'
require 'capybara/webkit/driver'
require 'mini_magick'

describe Capybara::Webkit::Driver, "rendering an image" do
  include AppRunner

  let(:driver) do
    driver_for_html(<<-HTML)
      <html>
        <body>
          <h1>Hello World</h1>
        </body>
      </html>
    HTML
  end

  before(:each) do
    # Set up the tmp directory and file name
    tmp_dir    = File.join(PROJECT_ROOT, 'tmp')
    FileUtils.mkdir_p tmp_dir
    @file_name = File.join(tmp_dir, 'render-test.png')
    driver.visit("#{AppRunner.app_host}/")
  end

  def render(options)
    FileUtils.rm_f @file_name
    driver.save_screenshot @file_name, options

    @image = MiniMagick::Image.open @file_name
  end

  context "with default options" do
    before { render({}) }

    it "should be a PNG" do
      expect(@image[:format]).to eq "PNG"
    end

    it "width default to 1000px (with 15px less for the scrollbar)" do
      expect(@image[:width]).to be < 1001
      expect(@image[:width]).to be > 1000-17
    end

    it "height should be at least 10px" do
      expect(@image[:height]).to be >= 10
    end
  end

  context "with dimensions set larger than necessary" do
    before { render(:width => 500, :height => 400) }

    it "width should match the width given" do
      expect(@image[:width]).to eq 500
    end

    it "height should match the height given" do
      expect(@image[:height]).to eq 400
    end

    it "should reset window dimensions to their default value" do
      expect(driver.evaluate_script('window.innerWidth')).to eq 1680
      expect(driver.evaluate_script('window.innerHeight')).to eq 1050
    end
  end

  context "with dimensions set smaller than the document's default" do
    before { render(:width => 50, :height => 10) }

    it "width should be greater than the width given" do
      expect(@image[:width]).to be > 50
    end

    it "height should be greater than the height given" do
      expect(@image[:height]).to be > 10
    end

    it "should restore viewport dimensions after rendering" do
      expect(driver.evaluate_script('window.innerWidth')).to eq 1680
      expect(driver.evaluate_script('window.innerHeight')).to eq 1050
    end
  end

  context "with a custom viewport size" do
    before { driver.resize_window(800, 600) }

    it "should restore viewport dimensions after rendering" do
      render({})
      expect(driver.evaluate_script('window.innerWidth')).to eq 800
      expect(driver.evaluate_script('window.innerHeight')).to eq 600
    end
  end

  context "with invalid filepath" do
    before do
      @file_name = File.dirname(@file_name)
    end

    it "raises an InvalidResponseError" do
      expect { render({}) }.to raise_error(Capybara::Webkit::InvalidResponseError)
    end
  end
end