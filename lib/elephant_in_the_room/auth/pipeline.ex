defmodule ElephantInTheRoom.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :elephant_in_the_room,
    error_handler: ElephantInTheRoom.Auth.ErrorHandler,
    module: ElephantInTheRoom.Auth.Guardian

  if Mix.env() == :test do
    plug Guardian.Plug.Backdoor, module: ElephantInThRoom.Guardian
  end
  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})

  # If there is an authorization header, validate it
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})

  # Load the user if either of the verifications worked
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
