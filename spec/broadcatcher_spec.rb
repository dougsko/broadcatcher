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

  it "parses feed" do
      @bc.read_config
      feed = { "name" => "rss_specs",
               "regex_false" => "use",
               "save_dir" => "/tmp",
               "url" => "http://www.rss-specifications.com/rss-podcast.xml",
               "regex_true" => ".*",
               "scan_time" => "60",
               "min_size" => "0",
               "max_size" => "2048",
      }
      rss = @bc.parse_feed(feed)
      rss.channel.title.should match(/RSS Feed Podcast/)
  end



end
