defmodule ElephantInTheRoom.Auth.Guardian do
  use Guardian, otp_app: :elephant_in_the_room

  alias ElephantInTheRoom.Auth

  @doc """
  returns something that can identify the user (the id field). 

  """
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @doc """
  extracts an id from the claims of JWT and return the matching user.

  """
  def resource_from_claims(claims) do
    user =
      claims["sub"]
      |> Auth.get_user()
  end
end
