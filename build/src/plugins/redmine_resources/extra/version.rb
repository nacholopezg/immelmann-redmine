#!/usr/bin/ruby

require "fileutils"
require "date"

GPL2_HEADER = "# This file is a part of Redmine Resources (redmine_resources) plugin,
# resource allocation and management for Redmine
#
# Copyright (C) 2011-#{Date.today.year} RedmineUP
# http://www.redmineup.com/
#
# redmine_resources is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_resources is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_resources.  If not, see <http://www.gnu.org/licenses/>.

".freeze

PROPRIETARY_HEADER = "/*
This file is a part of Redmine Resources (redmine_resources) plugin,
resource allocation and management for Redmine

Copyright (C) 2011-#{Date.today.year} RedmineUP
http://www.redmineup.com/

This file is covering by RedmineUP Proprietary Use License as any images, 
cascading stylesheets, manuals and JavaScript files in any extensions 
produced and/or distributed by redmineup.com. These files are copyrighted by 
redmineup.com (RedmineUP) and cannot be redistributed in any form 
without prior consent from redmineup.com (RedmineUP)

*/
".freeze

def add_gpl2_license_header(files)
  files.each do |file_name|
    file_content = File.read(file_name)
    file_content = (file_name.match(/.*\.(js|css)/) ? PROPRIETARY_HEADER : GPL2_HEADER) + file_content
    file_content = "# encoding: utf-8\n#\n" + file_content if file_name.match(/.*_(test|helper)\.rb/)
    File.open(file_name, "w") {|file| file.puts file_content}
  end
end

plugin_dir = File.expand_path('../', File.dirname(__FILE__))

add_gpl2_license_header(Dir["#{plugin_dir}/**/*.js"])
add_gpl2_license_header(Dir["#{plugin_dir}/**/*.css"])
add_gpl2_license_header(Dir["#{plugin_dir}/**/*.rb"])

FileUtils.rm_r Dir["#{plugin_dir}/.drone.yml"], :force => true
