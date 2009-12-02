#!/usr/bin/env ruby
#
#
# Handles downloading of files and checking for dups.
#

require 'yaml'
require 'rss'
require 'open-uri'

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
    end

    def download
        @config[:feeds].each do |feed|
            #Thread.new{
                while true do
                    rss_feed = feed["url"]
                    rss_content = ""
                    open(rss_feed) do |f|
                        rss_content = f.read
                    end
                    rss = RSS::Parser.parse(rss_content, false)
                    rss.channel.items.each do |item|
                        url = URI.parse(item.enclosure.url)
                        url.open do |file_to_get|
                            if item.description[/Filename: (.*);/]
                                file_name = "#{$1.gsub(/ /, '_').gsub(/,/, '')}.torrent"
                            else
                                url.path.match(/\/([^\/]*)$/)
                                file_name = $1.gsub(/ /, '_').gsub(/,/, '')
                            end
                            File.open("#{feed['save_dir']}/#{file_name}", 'w') do |file|
                                file << file_to_get.read
                            end
                        end
                    end
                    sleep feed["scan_time"]
                end
            #}.join
        end
    end

end

