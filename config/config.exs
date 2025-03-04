import Config

# Default configuration
config :bento_sdk,
  site_uuid: System.get_env("BENTO_SITE_UUID", "your_site_uuid"),
  username: System.get_env("BENTO_USERNAME", "your_username"),
  password: System.get_env("BENTO_PASSWORD", "your_password")

# Import environment specific config
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
