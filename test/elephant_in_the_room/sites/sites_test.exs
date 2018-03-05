defmodule ElephantInTheRoom.SitesTest do
  use ElephantInTheRoom.DataCase

  alias ElephantInTheRoom.Sites
  alias ElephantInTheRoom.Repo

  describe "sites" do
    alias ElephantInTheRoom.Sites.Site

    @valid_attrs %{name: "some site name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def site_fixture(attrs \\ %{}) do
      {:ok, site} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_site()

      site
    end

    test "list_sites/0 returns all sites" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      assert Sites.list_sites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :posts, :tags])

      assert Sites.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      assert {:ok, %Site{} = site} = Sites.create_site(@valid_attrs)
      assert site.name == "some site name"
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
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

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

    @valid_attrs %{description: "some category description", name: "some category name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def category_fixture(site, attrs \\ %{}) do
      attrs1 = Enum.into(attrs, @valid_attrs)

      {:ok, category} =
        site
        |> Sites.create_category(attrs1)

      category
    end

    test "list_categories/1 returns all categories" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category =
        category_fixture(site)
        |> Repo.preload(:site)

      assert Sites.list_categories(site) == [category]
    end

    test "get_category!/1 returns the category with given id" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category = category_fixture(site)
      assert Sites.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      site = site_fixture()
      assert {:ok, %Category{} = category} = Sites.create_category(site, @valid_attrs)
      assert category.description == "some category description"
      assert category.name == "some category name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.create_category(site, @invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category = category_fixture(site)
      assert {:ok, category} = Sites.update_category(category, @update_attrs)
      assert %Category{} = category
      assert category.description == "some updated description"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category = category_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_category(category, @invalid_attrs)
      assert category == Sites.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category = category_fixture(site)
      assert {:ok, %Category{}} = Sites.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      category = category_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_category(category)
    end
  end

  describe "posts" do
    alias ElephantInTheRoom.Sites.Post

    @valid_attrs %{
      content: "some post content",
      image: "some post image",
      title: "some post title"
    }
    @update_attrs %{
      content: "some updated content",
      image: "some updated image",
      title: "some updated title"
    }
    @invalid_attrs %{content: nil, image: nil, title: nil}

    def post_fixture(site, attrs \\ %{}) do
      attrs1 = Enum.into(attrs, @valid_attrs)

      {:ok, post} =
        site
        |> Sites.create_post(attrs1)

      post
    end

    test "list_posts/0 returns all posts" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert Sites.list_posts(site) == [post]
    end

    test "get_post!/2 returns the post with given id" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert Sites.get_post!(site, post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      assert {:ok, %Post{} = post} = Sites.create_post(site, @valid_attrs)
      assert post.content == "some post content"
      assert post.image == "some post image"
      assert post.title == "some post title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      assert {:error, %Ecto.Changeset{}} = Sites.create_post(site, @invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert {:ok, post} = Sites.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.content == "some updated content"
      assert post.image == "some updated image"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_post(post, @invalid_attrs)
      assert post == Sites.get_post!(site, post.id)
    end

    test "delete_post/1 deletes the post" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert {:ok, %Post{}} = Sites.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_post!(site, post.id) end
    end

    test "change_post/1 returns a post changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      post = post_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_post(post)
    end
  end

  describe "tags" do
    alias ElephantInTheRoom.Sites.Tag

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def tag_fixture(site, attrs \\ %{}) do
      attrs1 = Enum.into(attrs, @valid_attrs)

      {:ok, tag} =
        site
        |> Sites.create_tag(attrs1)

      tag
    end

    test "list_tags/1 returns all tags" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag =
        tag_fixture(site)
        |> Repo.preload(:site)

      assert Sites.list_tags(site) == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag = tag_fixture(site)
      assert Sites.get_tag!(site, tag.id) == tag
    end

    test "create_tag/2 with valid data creates a tag" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      assert {:ok, %Tag{} = tag} = Sites.create_tag(site, @valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/2 with invalid data returns error changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      assert {:error, %Ecto.Changeset{}} = Sites.create_tag(site, @invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag = tag_fixture(site)
      assert {:ok, tag} = Sites.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag = tag_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Sites.update_tag(tag, @invalid_attrs)
      assert tag == Sites.get_tag!(site, tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag = tag_fixture(site)
      assert {:ok, %Tag{}} = Sites.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_tag!(site, tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      site =
        site_fixture()
        |> Repo.preload([:categories, :tags, :posts])

      tag = tag_fixture(site)
      assert %Ecto.Changeset{} = Sites.change_tag(tag)
    end
  end
end
