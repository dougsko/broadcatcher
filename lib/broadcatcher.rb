#!/usr/bin/env ruby
#
#
# Handles downloading of files and checking for dups.
#

require 'yaml'
require 'rss'
require 'open-uri'
require 'logger'
require 'lib/item_handler'

class Broadcatcher
    def initialize
        @config_file = "#{ENV['HOME']}/.broadcatcher/config.yml"
    end

    def create_config(output=@config_file)
        File.open(output, 'w') do |f|
            config = { :working_dir => "#{ENV['HOME']}/.broadcatcher/",
                       :db_file => "#{ENV['HOME']}/.broadcatcher/downloaded.sqlite",
                       :log => "#{ENV['HOME']}/.broadcatcher/log.txt",
                       :feeds => [{'name' => 'example feed',
                                   'url' => 'http://foo',
                                   'save_dir' => "#{ENV['HOME']}/torrents",
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

    def read_config(input=@config_file)
        File.open(input, 'r') do |f|
            @config = YAML.load(f)
        end
        @log = Logger.new(@config[:log])
        @config
    end

    def run
        read_config
        threads = []
        @config[:feeds].each do |feed|
            threads << Thread.new do
                while true do
                    ih = ItemHandler.new(feed, @log)
                    ih.parse_feed do |item|
                        if ih.regex_true? and not ih.regex_false? and ih.size_ok? and not ih.downloaded?
                            ih.download
                        end
                    end
                    sleep feed["scan_time"]
                end
            end
        end
        threads.each do |thread|
            @log.debug "Joining thread"
            thread.join
        end
    end
end

#bc = Broadcatcher.new
#bc.run
