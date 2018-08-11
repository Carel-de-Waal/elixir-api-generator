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

 Adding associations
 Update models:
  user has many search_queries example:

  In search_queries.ex
    #field :user_id, :id
    belongs_to :user, Auth.User
  then in user.ex add in schema:
    has_many :search_queries, MakerMarket.API.SearchQuery

  To display assoc in json:
    def list_users do
      Repo.all(User) |> Repo.preload(:search_queries)
    end

    def render("user.json", %{user: user}) do
      %{id: user.id,
        email: user.email,
        is_active: user.is_active,
        search_queries: render_many(user.search_queries, SearchQueryView,"search_query.json")}
    end