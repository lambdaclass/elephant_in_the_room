defmodule ElephantInTheRoom.Auth.Guardian do
  use Guardian, otp_app: :elephant_in_the_room

  alias ElephantInTheRoom.Auth

  @doc """
  returns something that can identify the user (the id field). 

  """
  def subject_for_token(user, _claims) do
    inserted_at = to_string(user.inserted_at)
    id = to_string(user.id)
    token = "#{id},#{inserted_at}"
    {:ok, token}
  end

  @doc """
  extracts an id from the claims of JWT and return the matching user.

  """
  def resource_from_claims(claims) do
    token = claims["sub"]
    [id | _] = String.split(token, ",")
    Auth.get_user(id)
  end
end
