defmodule ElephantInTheRoomWeb.Uploaders.Postgresql do
  alias ElephantInTheRoom.Sites

  def put(_definition, version, {file, _scope}) do
    binary =
      if file.binary do
        file.binary
      else
        File.read!(file.path)
      end

    name =
      case version do
        :original ->
          file.file_name
        :thumb ->
          file.file_name <> "thumb"
      end

    {:ok, saved_image} = Sites.create_image(%{name: name, binary: binary})
    {:ok, saved_image.name}
  end

  def url(_definition, version, file_and_scope, _options \\ []) do
    name =
      case version do
        :original ->
          elem(file_and_scope, 0).file_name
        :thumb ->
          elem(file_and_scope, 0).file_name <> "thumb"
    end

    "/images/" <> name
    |> URI.encode()
  end

end
