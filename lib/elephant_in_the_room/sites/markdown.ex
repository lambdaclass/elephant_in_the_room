defmodule ElephantInTheRoom.Sites.Markdown do
  import Ecto.Changeset
  alias Ecto.Changeset

  def put_rendered_content(%Changeset{valid?: valid?} = changeset)
      when not valid?,
      do: changeset

  def put_rendered_content(%Changeset{} = changeset) do
    case get_field(changeset, :content) do
      nil ->
        rendered_content = generate_markdown("")

        put_change(changeset, :rendered_content, rendered_content)

      content ->
        rendered_content = generate_markdown(content)

        changeset
        |> put_change(:rendered_content, rendered_content)
        |> validate_length(:rendered_content, min: 1)
    end
  end

  def generate_markdown(input), do: Cmark.to_html(input, [:hardbreaks])
end
