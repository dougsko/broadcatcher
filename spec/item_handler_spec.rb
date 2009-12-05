require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ItemHandler" do
  before do
      @log = Logger.new("/dev/null")
      @feed = { "name" => "rss_specs",
               "regex_false" => "use",
               "save_dir" => "/tmp",
               "url" => "http://www.rss-specifications.com/rss-podcast.xml",
               "regex_true" => ".*",
               "scan_time" => "60",
               "min_size" => "0",
               "max_size" => "2048",
            }
  end

  it "new ItemHandler" do
      @bc = Broadcatcher.new
      @bc.create_config("/tmp/config.yml")
      @bc.read_config("/tmp/config.yml")
      @ih = ItemHandler.new(@feed, @log)
      @ih.class.to_s.should match(/ItemHandler/)
  end

  it "parses feed" do
      @ih = ItemHandler.new(@feed, @log)
      @ih.parse_feed do |item|
          item.class.to_s.should match(/RSS.*Item/)
      end
  end


end
