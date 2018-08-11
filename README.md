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

 Force forgein relations on create:
  In changeset add association id:
    validate_required([:query, :user_id])

 Rendering associations in JSON response:
  In context:
    def list_users do
      Repo.all(User) |> Repo.preload(:search_queries)
    end
  In views:
    def render("user.json", %{user: user}) do
      %{id: user.id,
        email: user.email,
        is_active: user.is_active,
        search_queries: render_many(user.search_queries, SearchQueryView,"search_query.json")}
    end