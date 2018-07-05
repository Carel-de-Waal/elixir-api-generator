#!/usr/bin/ruby
class String
 def snakecase
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    downcase
  end
end

puts "App name in CamelCase:"
# app_name_camel = gets
app_name_camel = "MakerMarket"
puts "app_name_camel: #{app_name_camel}"
app_name = app_name_camel.snakecase
puts "app_name: #{app_name}"

puts "Sql filename of file to import:"
#filename = gets
filename = "test-models.sql"


`cp -rf example-app #{app_name}`

thread = Thread.new do
  system("find ./#{app_name} -type f | xargs sed -i \"s/ExampleApp/"+app_name_camel+"/g\"")
end
thread.join

thread = Thread.new do
  system("find ./#{app_name} -type f | xargs sed -i \"s/example_app/"+app_name+"/g\"")
end
thread.join



puts "#### GO ####"

# in_table = false
# table_end_bracket_count = 0

# File.open(File.dirname(__FILE__) + "/" + filename, "r") do |f|
#   f.each_line do |line|

#     if(/CREATE TABLE.*/.match(line))
#       puts  "tablename: " + line[/`[a-zA-Z]+`.`[a-zA-Z]+`/].tr("`","").split(".").last
#       in_table = true
#       table_end_bracket_count = 1
#       next
#     end

#     if(in_table)
#       entry = line[/`[a-zA-Z]+` [A-Z0-9()]+ /].to_s.strip
#       if(entry != "")
#         col_raw = entry[/`[a-zA-Z]+`/]
#         col = col_raw.tr("`","")
#         type = entry.tr(col_raw, "").strip
#         puts "\t col: " + col + ", type: " + type
#       end
#       table_end_bracket_count += line.count("(")
#       table_end_bracket_count -= line.count(")")
#       if(table_end_bracket_count==0)
#         in_table=false
#         puts "End of table"
#       end
#     end

#   end



