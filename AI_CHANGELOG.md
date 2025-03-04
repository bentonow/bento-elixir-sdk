# AI Changelog

All notable changes to the BentoSdk project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Created comprehensive Livebook documentation for all API categories:
  - `events_api.livemd`: Interactive examples for tracking and importing events
  - `emails_api.livemd`: Interactive examples for sending regular and transactional emails
  - `tags_api.livemd`: Interactive examples for managing subscriber tags
  - `fields_api.livemd`: Interactive examples for managing subscriber custom fields
  - `broadcasts_api.livemd`: Interactive examples for creating and managing broadcasts
  - `stats_api.livemd`: Interactive examples for retrieving various statistics
  - `spam_api.livemd`: Interactive examples for email validation and risk assessment
  - `utility_api.livemd`: Interactive examples for content moderation, gender guessing, and geolocation
- Updated `index.livemd` to include links to all new Livebook files
- Enhanced README.md with comprehensive documentation of all Livebook resources
- Added new Utility API methods:
  - `moderate_content/1`: Check content for profanity and inappropriate content
  - `guess_gender/1`: Guess the gender of a name
  - `geolocate/1`: Get geolocation information for an IP address
- Added tests for utility API methods to ensure complete test coverage

### Changed
- Simplified Livebook documentation by replacing Kino forms with static example code
- Improved credential management using Livebook's secrets feature with "LB_" prefix
- Fixed duplicate function definition for `jesses_ruleset_reasons/2` in bento_sdk.ex
- Enhanced example code with clear comments and consistent formatting
- Streamlined configuration across all Livebook notebooks
- Fixed examples for `create_subscriber` and `find_or_create_subscriber` to correctly pass email as a separate parameter instead of including it in the attrs map, aligning with the Bento API requirements
- Modified `create_subscriber` and `find_or_create_subscriber` functions to only accept email parameter, removing the attrs parameter for simplicity and better API alignment
- Updated configuration documentation in README.md and module documentation to correctly reflect the environment variable approach used in config.exs

## [0.3.0] - 2025-03-04

### Added
- Implemented Livebook's secrets feature across all documentation notebooks
- Credentials are stored with "LB_" prefix to work with Livebook's environment variables
- This allows users to securely store their Bento credentials between sessions
- Credentials are now shared across all Livebook notebooks

## [0.1.0] - 2023-06-01

### Added
- Initial release of BentoSdk
- Core functionality for interacting with Bento API
- Support for Subscribers API
- Support for Events API
- Support for Emails API
- Support for Spam API
- Basic Livebook documentation
- Mocking support for testing
- Comprehensive README with usage examples
