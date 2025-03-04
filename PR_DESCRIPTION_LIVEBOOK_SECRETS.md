Title: [docs] Implement Livebook secrets feature for credential management

Summary:
Improved the developer experience by implementing Livebook's secrets feature across all documentation notebooks, allowing users to securely store and share their Bento credentials between sessions.
- Added simple form-based UI for saving credentials as Livebook secrets with "LB_" prefix
- Implemented System.get_env fallback to support both environment variables and Livebook secrets
- Ensured credentials are properly validated before configuring the SDK

Testing:
Manually verified that credentials can be saved and retrieved across all Livebook notebooks. Confirmed that the secrets are properly stored in Livebook's session with the "LB_" prefix and can be accessed by all notebooks.
