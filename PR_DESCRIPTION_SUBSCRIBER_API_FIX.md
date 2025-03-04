Title: [api] Simplify subscriber API functions to only use email parameter

Summary:
Simplified the subscriber API functions to only accept email parameter, removing the attrs parameter for better API alignment and simplicity.
- Modified `create_subscriber` to only accept email parameter
- Modified `find_or_create_subscriber` to only accept email parameter
- Updated all Livebook examples to use the simplified API
- Updated tests to match the new function signatures

Testing:
Verified that the updated functions work correctly with the Bento API. All tests have been updated to match the new function signatures and pass successfully.
