require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Broadcatcher" do
  before do
      @bc = Broadcatcher.new
  end

  it "new broadcatcher" do
    @bc.class.to_s.should match(/Broadcatcher/)
  end

  it "creates a config file" do
      @bc.create_config
      a = File.exists? "#{ENV['HOME']}/.broadcatcher/config.yml"
      a.to_s.should match(/true/)
  end


end
