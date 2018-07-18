alias ElephantInTheRoomWeb.Faker, as: ElephantFaker

config = %{
  sites: 2,
  categories: 4,
  authors: 5,
  tags: 6,
  users: 6,
  posts: 15
}

authors = ElephantFaker.Author.insert_many(config.authors)
_users = ElephantFaker.User.insert_many(config.users)

for site <- ElephantFaker.Site.insert_many(config.sites) do
  categories = ElephantFaker.Category.insert_many(config.categories, %{"site" => site})
  tags = ElephantFaker.Tag.insert_many(config.tags, %{"site" => site})

  for _post <- 1..config.posts do
    random_author = Enum.random(authors)

    categories_name =
      categories
      |> Enum.take_random(Faker.random_between(0, config.categories))
      |> Enum.map(fn cat -> cat.name end)

    tag_string_list =
      tags
      |> Enum.take_random(Faker.random_between(1, config.tags))
      |> Enum.map(fn tag -> tag.name end)

    ElephantFaker.Post.insert_one(%{
      "site" => site,
      "author_id" => random_author.id,
      "categories" => categories_name,
      "tags" => tag_string_list
    })
  end
end

# empty site
ElephantFaker.Site.insert_one(config.sites + 1)
