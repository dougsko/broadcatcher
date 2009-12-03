#!/usr/bin/env ruby
#
#
# Handles downloading of files and checking for dups.
#

require 'yaml'
require 'rss'
require 'open-uri'
require 'digest/md5'
require 'lib/downloaded'
require 'logger'

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

    def download
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
                        url = URI.parse(item.enclosure.url)
                        if item.description[/Filename: (.*);/]
                            file_name = "#{$1.gsub(/ /, '_').gsub(/,/, '')}.torrent"
                        else
                            url.path.match(/\/([^\/]*)$/)
                            file_name = $1.gsub(/ /, '_').gsub(/,/, '')
                        end
                        
                        if ! file_name.match(Regexp.new(feed["regex_true"]))
                            @log.debug "#{file_name} does not match regex_true: #{feed["regex_true"]}"
                            next
                        end
                        
                        if feed["regex_false"] != ""
                            if file_name.match(Regexp.new(feed["regex_false"]))
                                @log.debug "#{file_name} matches regex_false: #{feed["regex_false"]}"
                                next
                            end
                        end

                        file_size = item.enclosure.length.to_i / 1024 / 1024
                        if file_size < feed["min_size"].to_i or file_size > feed["max_size"].to_i
                            @log.debug "#{file_name} fails the size requirements at #{file_size} MB"
                            next
                        end

                        # check with database
                        if Downloaded.first(:hash => Digest::MD5.hexdigest(file_name))
                            @log.debug "#{file_name} already downloaded"
                            next
                        else
                            Downloaded.new(:hash => Digest::MD5.hexdigest(file_name)).save
                            @log.debug "Adding #{file_name} to the database"
                        end
                        
                        @log.debug "Downloading #{file_name}"
                        url.open do |file_to_get|
                            File.open("#{feed['save_dir']}/#{file_name}", 'w') do |file|
                                file << file_to_get.read
                            end
                        end
                    end
                    @log.debug "#{feed['name']} sleeping for #{feed['scan_time']} seconds" 
                    sleep feed["scan_time"]
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
bc.download
