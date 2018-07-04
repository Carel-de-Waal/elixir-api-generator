
puts "Sql file to import:"
#filename = gets
filename = "test-models.sql"
puts "#### GO ####"

in_table = false
table_end_bracket_count = 0

File.open(File.dirname(__FILE__) + "/" + filename, "r") do |f|
  f.each_line do |line|

    if(/CREATE TABLE.*/.match(line))
      puts  "tablename: " + line[/`[a-zA-Z]+`.`[a-zA-Z]+`/].tr("`","").split(".").last
      in_table = true
      table_end_bracket_count = 1
      next
    end

    if(in_table)
      entry = line[/`[a-zA-Z]+` [A-Z0-9()]+ /].to_s.strip
      if(entry != "")
        col_raw = entry[/`[a-zA-Z]+`/]
        col = col_raw.tr("`","")
        type = entry.tr(col_raw, "").strip
        puts "\t col: " + col + ", type: " + type
      end
      table_end_bracket_count += line.count("(")
      table_end_bracket_count -= line.count(")")
      if(table_end_bracket_count==0)
        in_table=false
        puts "End of table"
      end
    end

  end
end
