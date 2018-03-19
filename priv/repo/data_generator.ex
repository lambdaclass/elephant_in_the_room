alias ElephantInTheRoomWeb.Faker

config = %{
  :sites => 5,
  :categories => 8,
  :authors => 100,
  :tags => 200,
  :users => 100,
  :posts => 20
}

authors = Faker.Author.insert_many(config[:authors])
users = Faker.User.insert_many(config[:users])

for site <- Faker.Site.insert_many(config[:sites]) do
  categories = Faker.Category.insert_many(config[:categories], %{site: site})
  tags = Faker.Tag.insert_many(config[:tags], %{site: site})

  random_author = Faker.Chooser.choose_one(authors)

  for post <- 1..config[:posts] do
    categories_name =
      Faker.Chooser.choose_n(:rand.uniform(5), categories)
      |> Enum.map(fn cat -> cat.name end)

    tags_separated_by_comma =
      Faker.Chooser.choose_n(:rand.uniform(10), tags)
      |> Enum.map(fn tag -> tag.name end)
      |> Enum.join(", ")

    Faker.Post.insert_one(%{
      site: site,
      author_id: random_author.id,
      categories: categories_name,
      tags_separated_by_comma: tags_separated_by_comma
    })
  end
end
