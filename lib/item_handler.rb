#!/usr/bin/env ruby
#
#
# Handles parsing and tests done on RSS items.
#

require 'open-uri'
require 'lib/downloaded'

class ItemHandler
    def initialize(feed, item)
        @feed = feed
        @item = item

        @url = URI.parse(@item.enclosure.url)
        if @item.description[/Filename: (.*);/]
            @file_name = "#{$1.gsub(/ /, '_').gsub(/,/, '')}.torrent"
        else
            @url.path.match(/\/([^\/]*)$/)
            @file_name = $1.gsub(/ /, '_').gsub(/,/, '')
        end

        @file_size = @item.enclosure.length.to_i / 1024 / 1024
    end

    def name
        @file_name
    end

    def size
        @file_size
    end

    def regex_true?
        regex_true = Regexp.new(@feed["regex_true"])
        if @file_name.match(regex_true)
            return true
        end
        false
    end

    def regex_false?
        regex_false = Regexp.new(@feed["regex_false"])
        if @file_name.match(regex_false)
            return false
        end
        true
    end

    def downloaded?
        if Downloaded.first(:hash => Digest::MD5.hexdigest(@file_name))
            return true
        end
        false
    end

    def size_ok?
        if @file_size < @feed["min_size"].to_i or @file_size > @feed["max_size"].to_i
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
        end
    end

end
