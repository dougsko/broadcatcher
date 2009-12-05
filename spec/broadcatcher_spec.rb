require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Broadcatcher" do
  before do
      @bc = Broadcatcher.new
  end

  it "new broadcatcher" do
    @bc.class.to_s.should match(/Broadcatcher/)
  end

  it "creates a config file" do
      @bc.create_config("/tmp/sample_config.yml")
      a = File.exists? "/tmp/sample_config.yml"
      a.to_s.should match(/true/)
  end

  it "reads config file" do
      config = @bc.read_config("/tmp/sample_config.yml")
      config[:feeds][0]['name'].should match(/example feed/)
  end

end
