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

  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end

def elixir_type(type)
  if type.include?("INT")
    return "integer"
  elsif type.include?("VARCHAR")
      return "text"
  elsif type.include?("DATETIME")
    return "utc_datetime"
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

thread = Thread.new do
  system("cd ./#{app_name} && mix deps.get && mix deps.compile")
end
thread.join

puts "#### GO ####"

in_table = false
table_end_bracket_count = 0
gen_str = ""

File.open(File.dirname(__FILE__) + "/" + filename, "r") do |f|
  f.each_line do |line|

    if(/CREATE TABLE.*/.match(line))
      table_name = line[/`[a-zA-Z]+`.`[a-zA-Z]+`/].tr("`","").split(".").last
      puts  "tablename: " + table_name
      model_name = table_name.camel_case
      gen_str = "mix phx.gen.json API #{model_name} #{table_name}"
      in_table = true
      table_end_bracket_count = 1
      next
    end

    if(in_table)
      entry = line[/`[a-zA-Z_]+` [A-Z0-9()]+ /].to_s.strip
      if(entry != "")
        col_raw = entry[/`[a-zA-Z_]+`/]
        col = col_raw.tr("`","")
        type = entry.tr(col_raw, "").strip
        if( col != "id" )
          puts "\t col: " + col + ", type: " + type
          gen_str += " "+col + ":" + elixir_type(type)
        end
      end
      table_end_bracket_count += line.count("(")
      table_end_bracket_count -= line.count(")")
      if(table_end_bracket_count==0)
        thread = Thread.new do
          system("cd ./#{app_name} && #{gen_str}")
        end
        thread.join
        gen_str = ""
        in_table=false
        puts "End of table"
      end
    end
  end
end



