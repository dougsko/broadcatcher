#!/usr/bin/env ruby
#
#
# Handles downloading of files and checking for dups.
#

require 'yaml'
require 'rss'
require 'open-uri'
require 'digest/md5'
require 'logger'
require 'lib/item_handler'

class Broadcatcher
    def initialize
        @config_file = "/home/doug/.broadcatcher/config.yml"
    end

    def create_config
        File.open(@config_file, 'w') do |f|
            config = { :working_dir => "/home/doug/.broadcatcher/",
                       :db_file => "/home/doug/.broadcatcher/downloaded.sqlite",
                       :log => "/home/doug/.broadcatcher/log.txt",
                       :feeds => [{'name' => 'example feed',
                                   'url' => 'http://foo',
                                   'save_dir' => '/home/doug/torrents',
                                   'regex_false' => 'mkv',
                                   'regex_true' => '.*',
                                   'scan_time' => '60',
                                   'min_size' => '3',
                                   'max_size' => '2048',
                                 }
                                ]
            }
        f.puts config.to_yaml  
        end
    end

    def read_config
        File.open(@config_file, 'r') do |f|
            @config = YAML.load(f)
        end
        @log = Logger.new(@config[:log])
    end

    def run
        read_config
        threads = []
        @config[:feeds].each do |feed|
            threads << Thread.new do
                #while true do
                    @log.debug "Getting #{feed['name']}"
                    rss_feed = feed["url"]
                    rss_content = ""
                    open(rss_feed) do |f|
                        rss_content = f.read
                    end
                    @log.debug "Parsing #{feed['name']}"
                    rss = RSS::Parser.parse(rss_content, false)
                    rss.channel.items.each do |item|

                        ih = ItemHandler.new(feed, item)
                        
                        if ih.regex_true? and ih.regex_false? and ih.size_ok? and not ih.downloaded?
                            ih.download
                        end
                    end

                    #sleep feed["scan_time"]
                #end
            end
        end
        threads.each do |thread|
            @log.debug "Joining thread"
            thread.join
        end
    end
end

bc = Broadcatcher.new
bc.run
