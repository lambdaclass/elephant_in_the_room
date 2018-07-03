defmodule ElephantInTheRoomWeb.Uploaders.Postgresql do
  alias ElephantInTheRoom.{Repo, Sites}

  def put(definition, version, {file, scope}) do
    binary =
      if file.binary do
        file.binary
      else
        File.read!(file.path)
      end

    [file_name, type] =
      file.file_name
      |> String.split(".")

    name =
      case version do
        :original ->
          file_name
        :thumb ->
          file_name <> "thumb"
      end

    {:ok, saved_image} = Sites.create_image(%{name: name, binary: binary, type: type})
  end

  def url(definition, version, file_and_scope, _options \\ []) do
    name =
      case version do
        :original ->
          elem(file_and_scope, 0).file_name
        :thumb ->
          elem(file_and_scope, 0).file_name <> "thumb"
    end

    "/images/search/" <> name
    |> URI.encode()
  end

  def delete(definition, version, file_and_scope) do
    # TODO
    # build_local_path(definition, version, file_and_scope)
    # |> File.rm()
  end
end
