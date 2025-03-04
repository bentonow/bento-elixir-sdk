ExUnit.start()
ExUnit.configure(exclude: [:external])

# Define a mock for the BentoSdk.Client
Mox.defmock(BentoSdk.ClientMock, for: BentoSdk.ClientBehaviour)

# Configure the SDK to use the mock in test environment
Application.put_env(:bento_sdk, :config, client: BentoSdk.ClientMock)
