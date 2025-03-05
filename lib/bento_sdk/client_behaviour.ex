defmodule BentoSdk.ClientBehaviour do
  @moduledoc """
  Behaviour for the Bento API client.
  This allows us to mock the client in tests.
  """

  # Subscriber methods
  @callback find_subscriber(email :: String.t()) ::
              {:ok, map() | nil} | {:error, String.t()}

  @callback create_subscriber(email :: String.t()) ::
              {:ok, map()} | {:error, String.t()}

  @callback find_or_create_subscriber(email :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback import_subscribers(subscribers :: list(map())) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback run_command(command :: String.t(), email :: String.t(), query :: any()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback add_tag(email :: String.t(), tag :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback add_tag_via_event(email :: String.t(), tag :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback remove_tag(email :: String.t(), tag :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback add_field(email :: String.t(), key :: String.t(), value :: any()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback remove_field(email :: String.t(), field :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback subscribe(email :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback unsubscribe(email :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback change_email(old_email :: String.t(), new_email :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  # Tag methods
  @callback get_tags() ::
              {:ok, list(map())} | {:error, String.t()}
              
  @callback create_tag(name :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  # Field methods
  @callback get_fields() ::
              {:ok, list(map())} | {:error, String.t()}
              
  @callback create_field(key :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  # Event methods
  @callback track_event(email :: String.t(), type :: String.t(), fields :: map(), details :: map()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback import_events(events :: list(map())) ::
              {:ok, map()} | {:error, String.t()}
              
  # Email methods
  @callback send_email(to :: String.t(), from :: String.t(), subject :: String.t(), html_body :: String.t(), personalizations :: map()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback send_transactional_email(to :: String.t(), from :: String.t(), subject :: String.t(), html_body :: String.t(), personalizations :: map()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback send_bulk_emails(emails :: list(map())) ::
              {:ok, map()} | {:error, String.t()}
              
  # Utility methods
  @callback moderate_content(content :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback guess_gender(name :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback geolocate(ip_address :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback validate_email(email :: String.t(), opts :: Keyword.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback jesses_ruleset(email :: String.t(), opts :: Keyword.t()) ::
              {:ok, list(String.t())} | {:error, String.t()}
              
  @callback check_blacklist(params :: map()) ::
              {:ok, map()} | {:error, String.t()}
              
  # Stats methods
  @callback get_site_stats() ::
              {:ok, map()} | {:error, String.t()}
              
  @callback get_segment_stats(segment_id :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback get_report_stats(report_id :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  @callback get_subscriber_growth(start_date :: String.t(), end_date :: String.t()) ::
              {:ok, map()} | {:error, String.t()}
              
  # Broadcast methods
  @callback get_broadcasts() ::
              {:ok, list(map())} | {:error, String.t()}
              
  @callback create_broadcasts(broadcasts :: list(map())) ::
              {:ok, map()} | {:error, String.t()}
end
