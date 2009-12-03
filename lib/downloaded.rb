#!/usr/bin/env/ruby
#
#
# Database for downloaded files
#

require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, "sqlite3://#{ENV['HOME']}/.broadcatcher/downloaded.sqlite")

class Downloaded
    include DataMapper::Resource

    property :id, Serial
    property :hash, String
end

#DataMapper.auto_migrate!


