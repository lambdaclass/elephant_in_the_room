defmodule ElephantInTheRoom.SitesTest do
  use ElephantInTheRoom.DataCase
  alias ElephantInTheRoom.Repo
  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Sites.{Author, Category, Post, Site, Tag}

  describe "sites" do
    alias ElephantInTheRoom.Sites.Site

    @valid_attrs %{"name" => "some name"}
    @update_attrs %{"name" => "some updated name"}
    @invalid_attrs %{"name" => nil}

    def site_fixture(attrs \\ %{}) do
      {:ok, site} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_site()

      site
      |> Repo.preload([:categories, :posts, :tags])
    end

    test "list_sites/0 returns all sites" do
      site = site_fixture()
      assert Sites.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Sites.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      assert {:ok, %Site{} = site} = Sites.create_site(@valid_attrs)
      assert site.name == "some name"
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, site} = Sites.update_site(site, @update_attrs)
      assert %Site{} = site
      assert site.name == "some updated name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site, @invalid_attrs)
      assert site == Sites.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Sites.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Sites.change_site(site)
    end
  end

  describe "categories" do
    alias ElephantInTheRoom.Sites.Category

    @valid_attrs %{"description" => "some description", "name" => "some name"}
    @update_attrs %{"description" => "some updated description", "name" => "some updated name"}
    @invalid_attrs %{"description" => nil, "name" => nil}

    def category_fixture(site, attrs \\ %{}) do
      new_attrs = Enum.into(attrs, @valid_attrs)

      {:ok, category} =
        site
        |> Sites.create_category(new_attrs)

      category
    end

    test "list_categories/0 returns all categories" do
      site = site_fixture()
      category = category_fixture(site)
      assert Sites.list_categories(site) == [category |> Repo.preload(:site)]
    end

    test "get_category!/1 returns the category with given id" do
      site = site_fixture()
      category = category_fixture(site)
      assert Sites.get_category!(site, category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      site = site_fixture()
      assert {:ok, %Category{} = category} = Sites.create_category(site, @valid_attrs)
      assert category.description == "some description"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.create_category(site, @invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      site = site_fixture()
      category = category_fixture(site)
      assert {:ok, category} = Sites.update_category(category, @update_attrs)
      assert %Category{} = category
      assert category.description == "some updated description"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      site = site_fixture()
      category = category_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_category(category, @invalid_attrs)
      assert category == Sites.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      site = site_fixture()
      category = category_fixture(site)
      assert {:ok, %Category{}} = Sites.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      site = site_fixture()
      category = category_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_category(category)
    end
  end

  describe "tags" do
    alias ElephantInTheRoom.Sites.Tag

    @valid_attrs %{"name" => "some name"}
    @update_attrs %{"name" => "some updated name"}
    @invalid_attrs %{"name" => nil}

    def tag_fixture(site, attrs \\ %{}) do
      new_attrs = Enum.into(attrs, @valid_attrs)

      {:ok, tag} =
        site
        |> Sites.create_tag(new_attrs)

      tag
    end

    test "list_tags/0 returns all tags" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert Sites.list_tags(site) == [tag |> Repo.preload(:site)]
    end

    test "get_tag!/1 returns the tag with given id" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert Sites.get_tag!(site, tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      site = site_fixture()
      assert {:ok, %Tag{} = tag} = Sites.create_tag(site, @valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.create_tag(site, @invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert {:ok, tag} = Sites.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_tag(tag, @invalid_attrs)
      assert tag == Sites.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert {:ok, %Tag{}} = Sites.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      site = site_fixture()
      tag = tag_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_tag(tag)
    end
  end

  describe "authors" do
    alias ElephantInTheRoom.Sites.Author

    @valid_attrs %{
      "description" => "some description",
      "image" => "some image",
      "name" => "some name"
    }
    @update_attrs %{
      "description" => "some updated description",
      "image" => "some updated image",
      "name" => "some updated name"
    }
    @invalid_attrs %{"description" => nil, "image" => nil, "name" => nil}

    def author_fixture(attrs \\ %{}) do
      {:ok, author} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_author()

      author
    end

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Sites.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Sites.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      assert {:ok, %Author{} = author} = Sites.create_author(@valid_attrs)
      assert author.description == "some description"
      assert author.image == "some image"
      assert author.name == "some name"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()
      assert {:ok, author} = Sites.update_author(author, @update_attrs)
      assert %Author{} = author
      assert author.description == "some updated description"
      assert author.image == "some updated image"
      assert author.name == "some updated name"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_author(author, @invalid_attrs)
      assert author == Sites.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Sites.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Sites.change_author(author)
    end
  end

  describe "posts" do
    alias ElephantInTheRoom.Sites.Post

    @valid_attrs %{
      "content" => "some content",
      "image" => "some image",
      "title" => "some title",
      "slug" => "",
      "abstract" => "some abstract"
    }
    @update_attrs %{
      "content" => "some updated content",
      "image" => "some updated image",
      "title" => "some updated title"
    }
    @invalid_attrs %{"content" => nil, "image" => nil, "title" => nil}

    def post_fixture(site, attrs \\ %{}) do
      author = author_fixture()

      tags =
        for i <- 0..3 do
          tag = tag_fixture(site, %{"name" => "tag #{i}"})
          tag.id
        end

      categories =
        for i <- 0..3 do
          category = category_fixture(site, %{"name" => "category #{i}"})
          category.name
        end

      new_attrs =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{"author" => author, "categories" => categories, "tags" => tags})

      {:ok, post} =
        site
        |> Sites.create_post(new_attrs)

      post
    end

    test "list_posts/0 returns all posts" do
      site = site_fixture()
      post = post_fixture(site)
      assert Sites.list_posts(site) == [post]
    end

    test "get_post!/1 returns the post with given id" do
      site = site_fixture()
      post = post_fixture(site)
      assert Sites.get_post!(site, post.id) == post |> Repo.preload([:author])
    end

    test "create_post/1 with valid data creates a post" do
      site = site_fixture()
      assert {:ok, %Post{} = post} = Sites.create_post(site, @valid_attrs)
      assert post.content == "some content"
      assert post.image == "some image"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.create_post(site, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      site = site_fixture()
      post = post_fixture(site)
      assert {:ok, post} = Sites.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.content == "some updated content"
      assert post.image == "some updated image"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      site = site_fixture()
      post = post_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_post(post, @invalid_attrs)
      assert Repo.preload(post, :author) == Sites.get_post!(site, post.id)
    end

    test "delete_post/1 deletes the post" do
      site = site_fixture()
      post = post_fixture(site)
      assert {:ok, %Post{}} = Sites.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_post!(site, post.id) end
    end

    test "change_post/1 returns a post changeset" do
      site = site_fixture()
      post = post_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_post(post)
    end
  end

  describe "images" do
    alias ElephantInTheRoom.Sites.Image

    @valid_attrs %{binary: "some binary", type: "some type"}
    @update_attrs %{binary: "some updated binary", type: "some updated type"}
    @invalid_attrs %{binary: nil, type: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Sites.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Sites.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Sites.create_image(@valid_attrs)
      assert image.binary == "some binary"
      assert image.type == "some type"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Sites.update_image(image, @update_attrs)
      assert %Image{} = image
      assert image.binary == "some updated binary"
      assert image.type == "some updated type"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_image(image, @invalid_attrs)
      assert image == Sites.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Sites.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Sites.change_image(image)
    end
  end

  describe "magazines" do
    alias ElephantInTheRoom.Sites.Magazine

    @valid_attrs %{cover: "some cover", description: "some description", title: "some title"}
    @update_attrs %{cover: "some updated cover", description: "some updated description", title: "some updated title"}
    @invalid_attrs %{cover: nil, description: nil, title: nil}

    def magazine_fixture(attrs \\ %{}) do
      {:ok, magazine} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_magazine()

      magazine
    end

    test "list_magazines/0 returns all magazines" do
      magazine = magazine_fixture()
      assert Sites.list_magazines() == [magazine]
    end

    test "get_magazine!/1 returns the magazine with given id" do
      magazine = magazine_fixture()
      assert Sites.get_magazine!(magazine.id) == magazine
    end

    test "create_magazine/1 with valid data creates a magazine" do
      assert {:ok, %Magazine{} = magazine} = Sites.create_magazine(@valid_attrs)
      assert magazine.cover == "some cover"
      assert magazine.description == "some description"
      assert magazine.title == "some title"
    end

    test "create_magazine/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_magazine(@invalid_attrs)
    end

    test "update_magazine/2 with valid data updates the magazine" do
      magazine = magazine_fixture()
      assert {:ok, magazine} = Sites.update_magazine(magazine, @update_attrs)
      assert %Magazine{} = magazine
      assert magazine.cover == "some updated cover"
      assert magazine.description == "some updated description"
      assert magazine.title == "some updated title"
    end

    test "update_magazine/2 with invalid data returns error changeset" do
      magazine = magazine_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_magazine(magazine, @invalid_attrs)
      assert magazine == Sites.get_magazine!(magazine.id)
    end

    test "delete_magazine/1 deletes the magazine" do
      magazine = magazine_fixture()
      assert {:ok, %Magazine{}} = Sites.delete_magazine(magazine)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_magazine!(magazine.id) end
    end

    test "change_magazine/1 returns a magazine changeset" do
      magazine = magazine_fixture()
      assert %Ecto.Changeset{} = Sites.change_magazine(magazine)
    end
  end
end
