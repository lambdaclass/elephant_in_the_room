alias ElephantInTheRoomWeb.Faker, as: ElephantFaker

config = %{
  sites: 2,
  magazines: 15,
  categories: 4,
  authors: 5,
  tags: 6,
  users: 6,
  site_posts: 30,
  magazine_posts: 3,
  ads: 14
}

authors = ElephantFaker.Author.insert_many(config.authors)
_users = ElephantFaker.User.insert_many(config.users)

for site <- ElephantFaker.Site.insert_many(config.sites) do
  magazines = ElephantFaker.Magazine.insert_many(config.magazines, %{"site_id" => site.id})
  categories = ElephantFaker.Category.insert_many(config.categories, %{"site" => site})
  tags = ElephantFaker.Tag.insert_many(config.tags, %{"site" => site})
  _ads = ElephantFaker.Ad.insert_many(config.ads, %{"site" => site})

  for _post <- 1..config.site_posts do
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

  for magazine <- magazines do
    ElephantFaker.Post.insert_many(config.magazine_posts, %{"magazine_id" => magazine.id})
  end
end

# empty site
ElephantFaker.Site.insert_one(config.sites + 1)
