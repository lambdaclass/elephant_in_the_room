defmodule ElephantInTheRoom.Sites.Feedback do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElephantInTheRoom.Sites.{Site, Feedback}

  schema "feedbacks" do
    field(:email, :string)
    field(:text, :string)

    belongs_to(:site, Site)

    timestamps()
  end

  @doc false
  def changeset(%Feedback{} = feedback, attrs) do
    feedback
    |> cast(attrs, [:email, :text, :site_id])
    |> validate_required([:text])
    |> validate_length(:text, max: 300)
    |> validate_format(:email, ~r/.+@.+\..+/i, message: "El e-mail con formato incorrecto.")
  end
end