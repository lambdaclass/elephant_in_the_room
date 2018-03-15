defmodule ElephantInTheRoom.Repo.Chooser do
  def choose_author(authors) do
    random_author_index = authors |> length |> :rand.uniform()
    IO.puts(random_author_index)
    authors |> Enum.at(random_author_index)
  end

  def choose_n(n, list) do
    set = MapSet.new()
    len = length(list)

    for _n <- 1..n do
      set |> MapSet.put(list |> Enum.at(:rand.uniform(len)))
    end

    MapSet.to_list(set)
  end
end

alias ElephantInTheRoomWeb.Faker
alias ElephantInTheRoom.Repo.Chooser

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

  posts =
    Faker.Post.insert_many(config[:posts], %{
      site: site,
      author: Chooser.choose_author(authors),
      categories: Chooser.choose_n(:rand.uniform(5), categories),
      tags: Chooser.choose_n(:rand.uniform(10), tags)
    })
end
