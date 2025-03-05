ExUnit.start()
ExUnit.configure(exclude: [:external])

# Define mocks
Mox.defmock(BentoSdk.ClientMock, for: BentoSdk.ClientBehaviour)
Mox.defmock(HTTPoison.Mock, for: HTTPoison.Base)

# Configure the SDK to use the mocks in test environment
Application.put_env(:bento_sdk, :config, [
  client: BentoSdk.ClientMock,
  site_uuid: "test_site_uuid",
  username: "test_username",
  password: "test_password"
])

# Replace HTTPoison with the mock
Application.put_env(:bento_sdk, :http_client, HTTPoison.Mock)
