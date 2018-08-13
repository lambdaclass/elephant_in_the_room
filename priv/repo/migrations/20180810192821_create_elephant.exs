defmodule ElephantInTheRoom.Repo.Migrations.CreateElephant do
  use Ecto.Migration

  def change do
    # Create backups
    create table(:backup_data) do
      add(:last_backup_name, :string)
      add(:last_backup_moment, :utc_datetime)
    end

    # Create roles
    create table(:roles) do
      add(:name, :string)

      timestamps()
    end

    create(unique_index(:roles, [:name]))

    # Create users
    create table(:users) do
      add(:username, :string)
      add(:firstname, :string)
      add(:lastname, :string)
      add(:email, :string)
      add(:password, :string)
      add(:role_id, references(:roles, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:email]))

    # Create images
    create table(:images) do
      add(:binary, :binary)
      add :name, :string

      timestamps()
    end

    # Create sites
    create table(:sites) do
      add(:name, :string)
      add(:host, :string)
      add(:description, :string)
      add(:image, :string)
      add(:favicon, :string)
      add(:title, :string)
      add(:post_default_image, :string)
      add(:ads_title, :string)
      timestamps()
    end

    create(unique_index(:sites, [:host]))
    create(unique_index(:sites, [:name]))

    # Create ads
    create table(:ads) do
      add(:name, :string)
      add(:content, :string)
      add(:rendered_content, :string)
      add(:pos, :integer, null: false)
      add(:site_id, references(:sites, on_delete: :delete_all), null: false)
      timestamps()
    end

    create(unique_index(:ads, [:name, :site_id], name: :unique_ad_name))

    # Create feedback
    create table(:feedbacks) do
      add(:text, :string)
      add(:email, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(index(:feedbacks, [:site_id]))

    # Create magazines
    create table(:magazines) do
      add :title, :string
      add :cover, :string
      add :description, :text
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end

    create(unique_index(:magazines, [:title, :site_id], name: :title_unique_index))
    create(index(:magazines, [:site_id]))

    # Create authors
    create table(:authors) do
      add(:name, :string)
      add(:image, :string)
      add(:description, :text)
      add(:is_columnist, :boolean)

      timestamps()
    end

    create(unique_index(:authors, [:name]))

    # Create categories
    create table(:categories) do
      add(:name, :string)
      add(:description, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:categories, [:name]))
    create(index(:categories, [:site_id]))

    # Create tags
    create table(:tags) do
      add(:name, :string)
      add(:color, :string)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:tags, [:name]))
    create(index(:tags, [:site_id]))

    # Create posts
    create table(:posts) do
      add(:title, :string)
      add(:slug, :string)
      add(:abstract, :text)
      add(:content, :text)
      add(:rendered_content, :text)
      add(:cover, :string)
      add(:thumbnail, :string)
      add(:site_id, references(:sites, on_replace: :delete, on_delete: :delete_all))
      add(:magazine_id, references(:magazines, on_delete: :delete_all))
      add(:author_id, references(:authors))
      add(:featured_level, :integer)

      timestamps()
    end

    create(unique_index(:posts, [:slug, :site_id], name: :slug_unique_index))
    create(index(:posts, [:site_id]))
    create(index(:posts, [:magazine_id]))

    # Create posts-categories
    create table(:posts_categories, primary_key: false) do
      add(:post_id, references(:posts, on_delete: :delete_all))
      add(:category_id, references(:categories), on_delete: :delete_all)
    end

    # Create posts-tags
    create table(:posts_tags, primary_key: false) do
      add(:post_id, references(:posts), on_delete: :delete_all)
      add(:tag_id, references(:tags), on_delete: :delete_all)
    end

    # Create featured_cached_posts
    create table(:featured_cached_posts) do
      add(:level, :integer)
      add(:post_id, references(:posts))
      add(:site_id, references(:sites))
    end
  end
end
