alias ElephantInTheRoomWeb.Faker

config = %{
  :sites => 5,
  :categories => 3,
  :authors => 10,
  :tags => 20,
  :users => 10,
  :posts => 20
}

authors = Faker.Author.insert_many(config[:authors])
_users = Faker.User.insert_many(config[:users])

for site <- Faker.Site.insert_many(config[:sites]) do
  categories = Faker.Category.insert_many(config[:categories], %{"site" => site})
  tags = Faker.Tag.insert_many(config[:tags], %{"site" => site})

  for _post <- 1..config[:posts] do
    random_author = Faker.Chooser.choose_one(authors)

    categories_name =
      Faker.Chooser.choose_n(:rand.uniform(5), categories)
      |> Enum.map(fn cat -> cat.name end)

    tags_separated_by_comma =
      Faker.Chooser.choose_n(:rand.uniform(10), tags)
      |> Enum.map(fn tag -> tag.name end)
      |> Enum.join(", ")

    Faker.Post.insert_one(%{
      "site" => site,
      "author_id" => random_author.id,
      "categories" => categories_name,
      "tags_separated_by_comma" => tags_separated_by_comma
    })
  end
end
