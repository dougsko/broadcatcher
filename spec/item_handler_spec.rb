require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ItemHandler" do
  it "new ItemHandler" do
      @bc = Broadcatcher.new
      @bc.create_config("/tmp/config.yml")
      @bc.read_config("/tmp/config.yml")
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
      item = rss.channel.items[0]
      @ih = ItemHandler.new(feed, item)
      @ih.class.to_s.should match(/ItemHandler/)
  end


end
