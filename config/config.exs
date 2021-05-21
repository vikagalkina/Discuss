# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :discuss,
  ecto_repos: [Discuss.Repo]

# Configures the endpoint
config :discuss, DiscussWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "34Z4MJ8BGq9q3zzqGIC1Del67FkwYaY0SFef23qrV669CUo5yJVxN56cWofc3fro",
  render_errors: [view: DiscussWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Discuss.PubSub,
  live_view: [signing_salt: "Of0/fYiZ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :ueberauth, Ueberauth,
       providers: [
         github: { Ueberauth.Strategy.Github, [default_scope: "user, public_repo"] }
       ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
       client_id: "b003f70880dd87177ec0",
       client_secret: "fb91f6268487418374d92cd194a512b6a3767d8e"
