defmodule ElephantInTheRoom.Sites.Markdown do
  import Ecto.Changeset
  alias Ecto.Changeset

  def put_rendered_content(%Changeset{valid?: valid?} = changeset)
      when not valid?,
      do: changeset

  def put_rendered_content(%Changeset{} = changeset) do
    content = get_field(changeset, :content)
    rendered_content = generate_markdown(content)

    put_change(changeset, :rendered_content, rendered_content)
    |> validate_length(:rendered_content, min: 1)
  end

  def generate_markdown(input), do: Cmark.to_html(input, [:safe, :hardbreaks])
end
