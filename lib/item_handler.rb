#!/usr/bin/env ruby
#
#
# Handles parsing and tests done on RSS items.
#

require 'open-uri'
require 'lib/downloaded'

class ItemHandler
    def initialize(feed, log)
        @feed = feed
        @log = log
    end

    def name
        @url = URI.parse(@item.enclosure.url)
            if @item.description[/Filename: (.*);/]
                @file_name = "#{$1.gsub(/ /, '_').gsub(/,/, '')}.torrent"
            else
                @url.path.match(/\/([^\/]*)$/)
                @file_name = $1.gsub(/ /, '_').gsub(/,/, '')
            end
        @file_name
    end

    def size
        @file_size = @item.enclosure.length.to_i / 1024 / 1024
        @file_size
    end

    def parse_feed
        @log.debug "Getting #{@feed['name']}"
        rss_feed = @feed["url"]
        rss_content = ""
        open(rss_feed) do |f|
            rss_content = f.read
        end
        @log.debug "Parsing #{@feed['name']}"
        rss = RSS::Parser.parse(rss_content, false)
        rss.channel.items.each do |item|
            @item = item
            name
            size
            yield @item
        end
    end

    def regex_true?
        regex_true = Regexp.new(@feed["regex_true"])
        if @file_name.match(regex_true)
            return true
        end
        @log.debug "#{@file_name} did not match regex_true: #{regex_true}"
        false
    end

    def regex_false?
        regex_false = Regexp.new(@feed["regex_false"])
        if @file_name.match(regex_false)
            @log.debug "#{@file_name} did match regex_false: #{regex_false}"
            return true
        end
        false
    end

    def downloaded?
        if Downloaded.first(:hash => Digest::MD5.hexdigest(@file_name))
            @log.debug "#{@file_name} already downloaded"
            return true
        end
        false
    end

    def size_ok?
        if @file_size < @feed["min_size"].to_i or @file_size > @feed["max_size"].to_i
            @log.debug "#{@file_name} fails size check"
            return false
        end
        true
    end

    def download
        @url.open do |file_to_get|
            File.open("#{@feed['save_dir']}/#{@file_name}", 'w') do |file|
                file << file_to_get.read
            end
            Downloaded.new(:hash => Digest::MD5.hexdigest(@file_name)).save
            @log.debug "Downloaded #{@file_name}" 
        end
    end

end
