# elixir-api-generator

Use:
  gem install activesupport
  copy new [name].sql file to ./
  ruby sql-to-json-ap.rb
  cd [name]
  mix phx.server

Sign in:
 curl -H "Content-Type: application/json" -X POST -d '{"email":"admin","password":"12345678"}' http://localhost:4000/api/users/sign_in -c cookies.txt -b cookies.txt

Query:
 curl -H "Content-Type: application/json" -X GET http://localhost:4000/api/users -c cookies.txt -b cookies.txt -i