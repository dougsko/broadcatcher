require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Feed" do
    it "creates a new feed object" do
        @feed = Feed.new({'url' => "http://isohunt.com/js/rss/?iht=3",
                          'name' => "iso hunt tv",
                          'scan_time' => "100",
                          'save_folder' => '/tmp/',
                          'regex_false' => /720p/,
                          'regex_true' => /.*/
                         }
                        )
    end

    it "downloads a feed" do
        @feed.download
    end

end
