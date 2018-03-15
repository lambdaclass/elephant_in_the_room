alias ElephantInTheRoomWeb.Faker

config = %{
  :sites => 5,
  :categories => 8,
  :authors => 100,
  :tags => 200,
  :users => 100,
  :posts => 300
}

authors = Faker.Author.insert_many(config[:authors])
users = Faker.User.insert_many(config[:users])

for site <- Faker.Site.insert_many(config[:sites]) do
  categories = Faker.Category.insert_many(config[:categories], %{site: site})
  tags = Faker.Tag.insert_many(config[:tags], %{site: site})

  random_author = Faker.Chooser.choose_one(authors)

  categories_name =
    Faker.Chooser.choose_n(:rand.uniform(5), categories)
    |> Enum.map(fn cat -> cat.name end)

  tags_separated_by_comma =
    Faker.Chooser.choose_n(:rand.uniform(10), tags)
    |> Enum.map(fn tag -> tag.name end)
    |> Enum.intersperse(", ")

  posts =
    Faker.Post.insert_many(config[:posts], %{
      site: site,
      author_id: random_author.id,
      categories: categories_name,
      tags: tags_separated_by_comma
    })
end
