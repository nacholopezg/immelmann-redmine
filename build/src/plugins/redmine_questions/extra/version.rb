#!/usr/bin/env ruby

require "fileutils"
require "date"

GPL2_HEADER = "# This file is a part of Redmine Q&A (redmine_questions) plugin,
# Q&A plugin for Redmine
#
# Copyright (C) 2011-#{Date.today.year} RedmineUP
# http://www.redmineup.com/
#
# redmine_questions is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_questions is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_questions.  If not, see <http://www.gnu.org/licenses/>.

"
def pro_version(text)
  text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
  text = text.gsub(/(\s*(#|<!\-\-)\s*<BITNAMI>\s.*?<\/BITNAMI>[ ]*(\-\->)?)|(#\s<BITNAMI\s?\/>(.*?)\n{1})/m, "")
  text.gsub(/(\s*(#|<!\-\-)[ ]*<[\/]?PRO>[^\n\r]*(\-\->)*)|(\s*(#|<!\-\-)\s*<LIGHT>\s.*?<\/LIGHT>[ ]*(\-\->)?)|(#\s<LIGHT\s?\/>(.*?)\n{1})/m, "")
end

def light_version(text)
  text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
  text = text.gsub(/(\s*(#|<!\-\-)\s*<BITNAMI>\s.*?<\/BITNAMI>[ ]*(\-\->)?)|(#\s<BITNAMI\s?\/>(.*?)\n{1})/m, "")
  reg_light_block = /((#|<!--)\s(<LIGHT\/>|<LIGHT>|<LIGHT\s\/>)\s#?.*?((<\/LIGHT>)[ ]*(-->)?))/m
  reg_pro_block = /\s*(#|<!--)[ ]*<PRO>.*?<\/PRO>[ ]*(-->)*/m
  without_pro = text.gsub(reg_pro_block, "")
  light_text2 = /((#\s+)|(<LIGHT\/>)}|(<LIGHT>)|(<!\-\-)|(\-\->)|(<\/LIGHT>))/m
  without_pro.gsub!(reg_light_block){|pas| pas.gsub(light_text2, "")}
  #remove one line LIGHT tag
  without_pro.gsub(/(#\s<LIGHT\s?\/>\s?)/, "")
end

def add_gpl2_license_header(files)
  files.each do |file_name|
    next if file_name.match("version.rb")
    file_content = File.read(file_name)
    file_content = GPL2_HEADER + file_content
    file_content = "# encoding: utf-8\n#\n" + file_content if file_name.match(/.*_(test|helper)\.rb/)
    File.open(file_name, "w") {|file| file.puts file_content}
  end
end

plugin_dir = File.expand_path('../', File.dirname(__FILE__))

Dir["#{plugin_dir}/**/*.rb",
    "#{plugin_dir}/**/*.erb",
    "#{plugin_dir}/**/*.api.rsb",
    "#{plugin_dir}/Gemfile"].each do |file_name|
  next if file_name.match("version.rb")
  text = File.read(file_name)

  if ARGV && ARGV[0] == 'light'
    patched_file = light_version(text)
  else
    patched_file = pro_version(text)
  end

  File.open(file_name, "w") {|file| file.puts patched_file}
end

add_gpl2_license_header(Dir["#{plugin_dir}/**/*.rb"])

if ARGV && (ARGV[0] == 'light')
    FileUtils.rm_r Dir["#{plugin_dir}/app/**/*vote*",
                       "#{plugin_dir}/app/views/questions/_solution.*",
                       "#{plugin_dir}/app/views/questions/_idea.*",
                       "#{plugin_dir}/app/views/questions/_tag_cloud.*",
                       "#{plugin_dir}/app/views/questions/_form_tags.*",
                       "#{plugin_dir}/app/views/**/_question_item_vote.*",
                       "#{plugin_dir}/app/views/**/*with_popular_topics*",
                       "#{plugin_dir}/app/views/settings",
                       "#{plugin_dir}/test/**/questions_votes_controller_test.rb"],
                     :force => true
end

FileUtils.rm_r Dir["#{plugin_dir}/.drone.yml"], :force => true
