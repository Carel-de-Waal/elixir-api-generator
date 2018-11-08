#!/usr/bin/ruby
require 'stringio'
require 'active_support/all'


app_name_camel = "RasaHiguru"
filename = "rasa-higuru.sql"

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
   elsif type.include?("DECIMAL")
     return "decimal"
   elsif type.include?("VARCHAR")
       return "text"
   elsif type.include?("DATETIME")
     return "utc_datetime"
   elsif type.include?("BOOL")
     return "boolean"
   end
 end

 def foreign_key_col_name(line)
  foreign_key_line = line.match(/FOREIGN KEY \((`[a-zA-Z_]+`)\)/i)
  if(foreign_key_line)
    return foreign_key_line.captures.first.tr("`","")
  else
    return nil
  end
 end

 def forgein_key_tablename(line)
  line.match(/REFERENCES `[a-zA-Z_]+`.`([a-zA-Z_]+)` .*/i).captures.first.tr("`","")
 end

 def add_route(file_path, new_route_line)
   puts "add_route"
   output = StringIO.new

   File.foreach(file_path) do |line|
     if /pipe_through \[:api, :api_auth\]*/.match(line)
       output.puts line
       output.puts new_route_line
     else
       output << line
     end
   end

   output.rewind

   File.open(file_path, 'w') do |f|
     f.write output.read
   end
 end

 def add_association(file_path, app_name,table_name)
  puts "add_association"
  output = StringIO.new
  app_name_camel = app_name.camel_case.singularize
  File.foreach(file_path) do |line|
    if /field :([a-zA-z_]+)_id, :id/.match(line)
      model_name = /field :([a-zA-z_]+)_id, :id/.match(line)[1]
      if(model_name == "user")
        new_ass_line = "    belongs_to :user, Auth.User"
        has_many_file_path = File.dirname(__FILE__) + "/" + "#{app_name}/lib/#{app_name}/auth/user.ex"
      else
        new_ass_line = "    belongs_to :#{model_name}, #{app_name_camel}.Api.#{model_name.camel_case}"
        has_many_file_path = File.dirname(__FILE__) + "/" + "#{app_name}/lib/#{app_name}/api/#{model_name}.ex"
      end
      output.puts new_ass_line
      add_has_many(has_many_file_path, app_name_camel, table_name.singularize)
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def add_has_many(file_path, app_name_camel, model_name)
  puts "add_has_many"
  output = StringIO.new

  File.foreach(file_path) do |line|
    if /schema "[a-zA-Z_]+" do/.match(line)
      if(model_name == "user")
        new_ass_line = "    has_many :users, Auth.User"
      else
        new_ass_line = "    has_many :#{model_name.pluralize}, #{app_name_camel}.API.#{model_name.camel_case}"
      end
      output.puts line
      output.puts new_ass_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_controller_one(file_path, table_name)
  puts "update_controller_one"
  output = StringIO.new
  File.foreach(file_path) do |line|
    if /.*#{Regexp.escape(table_name)} = [a-zA-Z_]+\.list_#{Regexp.escape(table_name)}\(\)/.match(line)
      if(table_name == "users")
        new_line = "    page = Auth.list_users(params[\"page\"] || 1)"
      else
        new_line = "    page = API.list_#{table_name}(params[\"page\"] || 1)"
      end
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_controller_two(file_path, table_name)
  puts "update_controller_two"
  output = StringIO.new
  File.foreach(file_path) do |line|
    if /.*render\(conn, "index.json", #{Regexp.escape(table_name)}: #{Regexp.escape(table_name)}\)/.match(line)
      new_line = "    render(conn, \"index.json\", #{table_name}: page.entries, page_info: Map.delete(page, :entries))"
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_controller_three(file_path, table_name)
  puts "update_controller_three"
  output = StringIO.new
  File.foreach(file_path) do |line|
    if /.*def index\(conn, _params\) do/.match(line)
      new_line = "def index(conn, params) do"
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_context(file_path, table_name)
  puts "update_context"
  output = StringIO.new
  model_name = table_name.singularize.camel_case
  File.foreach(file_path) do |line|
    if /.*def list_#{Regexp.escape(table_name)} do/.match(line)
      new_line = " def list_#{table_name}(page) do"
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_context_two(file_path, table_name)
  puts "update_context_two"
  output = StringIO.new
  model_name = table_name.singularize.camel_case
  File.foreach(file_path) do |line|
    if /.*Repo\.all\(#{Regexp.escape(model_name)}\)/.match(line)
      if(table_name == "users")
        new_line = " User |> Repo.paginate(page: page)"
      else
        new_line = " #{model_name} |> Repo.paginate(page: page)"
      end
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_view(file_path, table_name)
  puts "update_view"
  output = StringIO.new
  model_name = table_name.singularize.camel_case
  File.foreach(file_path) do |line|
    if /.*def render\("index\.json",.*do/.match(line)
      new_line = "  def render(\"index.json\", %{#{table_name}: #{table_name}, page_info: page_info}) do"
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

def update_view_two(file_path, table_name)
  puts "update_view_two"
  output = StringIO.new
  model_name = table_name.singularize.camel_case
  File.foreach(file_path) do |line|
    if /.*%{data: render_many\(#{Regexp.escape(table_name)}, #{Regexp.escape(model_name)}View, "#{Regexp.escape(table_name.singularize)}\.json"\)}/.match(line)
      new_line = "  %{#{table_name}: render_many(#{table_name}, #{model_name}View, \"#{table_name.singularize}.json\"), page_info: page_info}"
      output.puts new_line
    else
      output << line
    end
  end

  output.rewind

  File.open(file_path, 'w') do |f|
    f.write output.read
  end
end

 def create_user_in_seed(app_name, seed_file_path, username, password)
  File.open(seed_file_path, 'a') do |f|
    f.puts  "#{app_name}.Auth.create_user(%{email: \"#{username}\", password: \"#{password}\"})"
  end
 end

 puts "App name in CamelCase:"
 #app_name_camel = gets.chop
 puts "app_name_camel: #{app_name_camel}"
 app_name = app_name_camel.snakecase
 puts "app_name: #{app_name}"

 #puts "Sql filename of file to import: (ex test.sql)"
 #filename = gets.chop

 `cp -rf example-app #{app_name}`

 thread = Thread.new do
   system("find ./#{app_name}/ -execdir rename 's/example-app/"+app_name+"/' '{}' \+")
 end
 thread.join

 thread = Thread.new do
   system("find ./#{app_name}/ -execdir rename 's/example_app/"+app_name+"/' '{}' \+")
 end
 thread.join

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

 thread = Thread.new do
   system("mv -f ./#{app_name}/lib/#{app_name}_web/views/changeset_view.ex ./changeset_view.ex.backup && mv -f ./#{app_name}/lib/#{app_name}_web/controllers/fallback_controller.ex ./fallback_controller.ex.backup")
 end
 thread.join

 puts "#### GO ####"
 file_path = File.dirname(__FILE__) + "/"
 `ls #{file_path}`
 in_table = false
 table_end_bracket_count = 0
 gen_str = ""
 table_name = ""
 next_line_forgein_key_name = nil
 File.open(file_path + filename, "r") do |f|
   f.each_line do |line|

     if(/CREATE TABLE.*/.match(line))
       table_name = line[/`[a-zA-Z_]+`.`[a-zA-Z_]+`/].tr("`","").split(".").last
       puts  "tablename: " + table_name
       model_name = table_name.camel_case.singularize
       if(table_name=="users")
        #Add pagination(Scriviner) to controller and view
        update_controller_one(file_path + "#{app_name}/lib/#{app_name}_web/controllers/user_controller.ex",table_name)
        update_controller_two(file_path + "#{app_name}/lib/#{app_name}_web/controllers/user_controller.ex",table_name)
        update_controller_three(file_path + "#{app_name}/lib/#{app_name}_web/controllers/user_controller.ex",table_name)
        update_context(file_path + "#{app_name}/lib/#{app_name}/auth/auth.ex",table_name)
        update_context_two(file_path + "#{app_name}/lib/#{app_name}/auth/auth.ex",table_name)
        update_view(file_path +  "#{app_name}/lib/#{app_name}_web/views/user_view.ex",table_name)
        update_view_two(file_path +  "#{app_name}/lib/#{app_name}_web/views/user_view.ex",table_name)
        next
       end
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
         if( col != "id" && !col.include?("_id"))
           puts "\t col: " + col + ", type: " + type
           gen_str += " "+col + ":" + elixir_type(type)
         end
       end
       if(next_line_forgein_key_name)
        forgein_key_tablename = forgein_key_tablename(line)
        gen_str += " #{next_line_forgein_key_name}:references:#{forgein_key_tablename}"
        next_line_forgein_key_name = nil
       else
        next_line_forgein_key_name = foreign_key_col_name(line)
       end

       table_end_bracket_count += line.count("(")
       table_end_bracket_count -= line.count(")")
       if(table_end_bracket_count==0)
         puts "End of table"
         thread = Thread.new do
          puts gen_str
           system("cd ./#{app_name} && #{gen_str}")
         end
         thread.join
         sleep 1
         add_route(file_path + "#{app_name}/lib/#{app_name}_web/router.ex", "  resources \"/#{table_name}\", #{table_name.camel_case.singularize}Controller, except: [:new, :edit]")
         add_association(file_path + "#{app_name}/lib/#{app_name}/api/#{table_name.singularize}.ex", app_name,table_name)
         #Add pagination(Scriviner) to controller and view
         update_controller_one(file_path + "#{app_name}/lib/#{app_name}_web/controllers/#{table_name.singularize}_controller.ex",table_name)
         update_controller_two(file_path + "#{app_name}/lib/#{app_name}_web/controllers/#{table_name.singularize}_controller.ex",table_name)
         update_controller_three(file_path + "#{app_name}/lib/#{app_name}_web/controllers/#{table_name.singularize}_controller.ex",table_name)
         if(table_name == "users")
          update_context(file_path + "#{app_name}/lib/#{app_name}/auth/auth.ex",table_name)
          update_context_two(file_path + "#{app_name}/lib/#{app_name}/auth/auth.ex",table_name)
         else
          update_context(file_path + "#{app_name}/lib/#{app_name}/api/api.ex",table_name)
          update_context_two(file_path + "#{app_name}/lib/#{app_name}/api/api.ex",table_name)
         end
         update_view(file_path +  "#{app_name}/lib/#{app_name}_web/views/#{table_name.singularize}_view.ex",table_name)
         update_view_two(file_path +  "#{app_name}/lib/#{app_name}_web/views/#{table_name.singularize}_view.ex",table_name)
         thread = Thread.new do
           cmd = "rm ./#{app_name}/lib/#{app_name}_web/views/changeset_view.ex"
           cmd += "&& rm ./#{app_name}/lib/#{app_name}_web/controllers/fallback_controller.ex"
           system(cmd)
         end
         thread.join

         gen_str = ""
         table_name = ""
         in_table=false
       end
     end
   end
 end

 thread = Thread.new do
   cmd = "cp ./changeset_view.ex.backup ./#{app_name}/lib/#{app_name}_web/views/changeset_view.ex"
   cmd += " && rm -f ./changeset_view.ex.backup"
   cmd += " && cp ./fallback_controller.ex.backup ./#{app_name}/lib/#{app_name}_web/controllers/fallback_controller.ex"
   cmd += " && rm -f ./fallback_controller.ex.backup"
   system(cmd )
 end
 thread.join

 create_user_in_seed(app_name.camel_case, file_path + "#{app_name}/priv/repo/seeds.exs", "admin", "12345678")
 thread = Thread.new do
   system("cd ./#{app_name} && mix ecto.create && mix ecto.migrate && mix run priv/repo/seeds.exs")
 end
 thread.join





