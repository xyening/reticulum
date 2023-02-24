use Mix.Config

# NOTE: this file contains some security keys/certs that are *not* secrets, and are only used for local development purposes.

host = "hubs.szcxkj.com"
cors_proxy_host = "hubs-proxy.local"
assets_host = "hubs-assets.local"
link_host = "hubs-link.local"

# To run reticulum across a LAN for local testing, uncomment and change the line below to the LAN IP
# host = cors_proxy_host = "192.168.1.27"

dev_janus_host = host

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ret, RetWeb.Endpoint,
  url: [scheme: "https", host: host, port: 443],
  static_url: [scheme: "https", host: host, port: 443],
  https: [
    port: 4000,
    otp_app: :ret,
    cipher_suite: :strong,
    keyfile: "/root/cert/cert.key",
    certfile: "/root/cert/cert.pem"
  ],
  cors_proxy_url: [scheme: "https", host: cors_proxy_host, port: 443],
  assets_url: [scheme: "https", host: assets_host, port: 443],
  link_url: [scheme: "https", host: link_host, port: 443],
  imgproxy_url: [scheme: "http", host: host, port: 5000],
  debug_errors: true,
  code_reloader: false, # this is important
  check_origin: false,
  # This config value is for local development only.
  secret_key_base: "txlMOtlaY5x3crvOCko4uV5PM29ul3zGo1oBGNO3cDXx+7GHLKqt0gR9qzgThxb5",
  allowed_origins: "*",
  allow_crawlers: true

# Do not include metadata nor timestamps in development logs
# config :logger, :console, format: "[$level] $message\n"
# Do not print debug messages in production
config :logger, level: :info
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

env_db_host = "#{System.get_env("DB_HOST")}"

# Configure your database
config :ret, Ret.Repo,
  username: "postgres",
  password: "postgres",
  database: "ret_dev",
  hostname: "localhost",
  template: "template0",
  pool_size: 10

config :ret, Ret.SessionLockRepo,
  username: "postgres",
  password: "postgres",
  database: "ret_dev",
  hostname: "localhost",
  template: "template0",
  pool_size: 10

config :ret, RetWeb.Plugs.HeaderAuthorization,
  header_name: "x-ret-admin-access-key",
  header_value: "admin-only"

config :ret, Ret.SlackClient,
  client_id: "",
  client_secret: "",
  bot_token: ""

# Token is our randomly generated auth token to append to Slacks slash command
# As a query param "token"
config :ret, RetWeb.Api.V1.SlackController, token: ""

config :ret, Ret.DiscordClient,
  client_id: "",
  client_secret: "",
  bot_token: ""

# Allow any origin for API access in dev
config :cors_plug, origin: ["*"]

config :ret,
  # This config value is for local development only.
  upload_encryption_key: "a8dedeb57adafa7821027d546f016efef5a501bd",
  bot_access_key: ""

config :ret, Ret.PageOriginWarmer,
  hubs_page_origin: "https://#{host}:8080",
  admin_page_origin: "https://#{host}:8989",
  spoke_page_origin: "https://#{host}:9090",
  insecure_ssl: true

# config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.Scheduler,
  jobs: [
    # Send stats to StatsD every 5 seconds
    {{:extended, "*/5 * * * *"}, {Ret.StatsJob, :send_statsd_gauges, []}},

    # Flush stats to db every 5 minutes
    {{:cron, "*/5 * * * *"}, {Ret.StatsJob, :save_node_stats, []}},

    # Keep database warm when connected users
    {{:cron, "*/3 * * * *"}, {Ret.DbWarmerJob, :warm_db_if_has_ccu, []}},

    # Rotate TURN secrets if enabled
    {{:cron, "*/5 * * * *"}, {Ret.Coturn, :rotate_secrets, []}},

    # Various maintenence routines
    {{:cron, "0 10 * * *"}, {Ret.Storage, :vacuum, []}},
    {{:cron, "3 10 * * *"}, {Ret.Storage, :demote_inactive_owned_files, []}},
    {{:cron, "4 10 * * *"}, {Ret.LoginToken, :expire_stale, []}},
    {{:cron, "5 10 * * *"}, {Ret.Hub, :vacuum_entry_codes, []}},
    {{:cron, "6 10 * * *"}, {Ret.Hub, :vacuum_hosts, []}},
    {{:cron, "7 10 * * *"}, {Ret.CachedFile, :vacuum, []}}
  ]

config :ret, Ret.MediaResolver,
  giphy_api_key: nil,
  deviantart_client_id: nil,
  deviantart_client_secret: nil,
  imgur_mashape_api_key: nil,
  imgur_client_id: nil,
  youtube_api_key: nil,
  sketchfab_api_key: nil,
  ytdl_host: nil,
  photomnemonic_endpoint: "https://uvnsm9nzhe.execute-api.us-west-1.amazonaws.com/public"

config :ret, Ret.Speelycaptor, speelycaptor_endpoint: "https://1dhaogh2hd.execute-api.us-west-1.amazonaws.com/public"

config :ret, Ret.Storage,
  host: "https://#{host}",
  storage_path: "/root/hubsr/reticulum/_work/reticulum/reticulum/storage",
  ttl: 60 * 60 * 24

asset_hosts =
  "https://localhost:4000 https://localhost:8080 " <>
    "https://#{host} https://#{host}:4000 https://#{host}:8080 https://#{host}:3000 https://#{host}:8989 https://#{host}:9090 https://#{
      cors_proxy_host
    }:4000 " <>
    "https://assets-prod.reticulum.io https://asset-bundles-dev.reticulum.io https://asset-bundles-prod.reticulum.io"

websocket_hosts =
  "https://localhost:4000 https://localhost:8080 wss://localhost:4000 " <>
    "https://#{host}:4000 https://#{host}:8080 wss://#{host}:4000 wss://#{host}:8080 wss://#{host}:8989 wss://#{host}:9090 " <>
    "wss://#{host}:4000 wss://#{host}:8080 https://#{host}:8080 https://localhost:8080 wss://localhost:8080"

config :ret, RetWeb.Plugs.AddCSP,
  script_src: asset_hosts,
  font_src: asset_hosts,
  style_src: asset_hosts,
  connect_src:
    "https://#{host}:8080 https://sentry.prod.mozaws.net #{asset_hosts} #{websocket_hosts} https://www.mozilla.org",
  img_src: asset_hosts,
  media_src: asset_hosts,
  manifest_src: asset_hosts

config :ret, Ret.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.qq.com",
  port: 465,
  username: "307840440@qq.com",
  password: "kjbmcggtogrwcaid",
  tls: always, # can be `:always` or `:never`
  ssl: true, # can be `true`
  retries: 1

config :ret, RetWeb.Email, from: "info@hubs-mail.com"

# config :ret, Ret.PermsToken, perms_key: (System.get_env("PERMS_KEY") || "") |> String.replace("\\n", "\n")

config :ret, Ret.PermsToken,
  # This config value is for local development only.
  perms_key:
    "-----BEGIN RSA PRIVATE KEY-----\nMIICWwIBAAKBgQDwB7YaEP7gtbnpbKQO9mvT8tYJlUIS3XQUJ+Xvrc29x97kUIuv\noqdzoOy8kxAtiQOyS72zQ0KQEP9jB3u7JVc3JJ4gsOzBsYylpuYutPNR0wbLdiSJ\nshq0Qf6KzfKnr7FhAQSZLl8YY+CYevVkk8pxulwBvFVnpHU0Tw1lTpiYHQIDAQAB\nAoGAMKnvkpNViWtumNOs41e0ftEh8elv7vE1Ao0gQhqjttFZ8EIgP+ijOH8s4AKU\n6hZ4SGKwwDJnwVug24v92vB0INZfTw4DgT+NcJtWasyJ3DctfpoSaCr3ZEEe3oRY\n0auJCkVDobdQuPzkZzyCkicuoEQHq1wI9LPtxGhtEOWbK2ECQQD+weO2+a97LYWU\nLZWDir96mNXAVbnJqM1/EHTGtXT39vCWRIsdYGS1e+HDDpitjwj4RJkKPoubhEKd\n0K51veOJAkEA8TNuo+5Yf0O0kVzADigSFafmV/Bouex5OA0rrh94CIoaIjs1riWi\ncdlfZvb8uf/Yr8AkNRRIZP1YdWKHb/um9QJAQkADyuqlst/EtCMilaG4Z9ZlB+6D\nMSkfv6J069P2hiGGsV1D3DDcH8IGlOYv2DqxN3cHYX2gaqH7fPTu2Zm3GQJADKZC\n3iwIzhvR43G2zMdDM4mLpf8Arwd8z/i42rfhxqjfd/4c8ZYdr9TTkQXQ+Tw2s/ji\nrTn0Ff/HXNie+7t55QJAfSP4WZAqzIWxguF1eD7rdk8WKIvjy0LH1i8iG54wHVhp\nA6dbqU2uuUKBtjycDwzxPmOStLIJmLrh9LaMiUJs/Q==\n-----END RSA PRIVATE KEY-----"


config :ret, Ret.OAuthToken, oauth_token_key: ""

config :ret, Ret.Guardian,
  issuer: "ret",
  # This config value is for local development only.
  secret_key: "47iqPEdWcfE7xRnyaxKDLt9OGEtkQG3SycHBEMOuT2qARmoESnhc76IgCUjaQIwX",
  ttl: {12, :weeks}

config :web_push_encryption, :vapid_details,
  subject: "mailto:admin@mozilla.com",
  public_key: "BAb03820kHYuqIvtP6QuCKZRshvv_zp5eDtqkuwCUAxASBZMQbFZXzv8kjYOuLGF16A3k8qYnIN10_4asB-Aw7w",
  # This config value is for local development only.
  private_key: "w76tXh1d3RBdVQ5eINevXRwW6Ow6uRcBa8tBDOXfmxM"

config :sentry,
  environment_name: :prod,
  json_library: Poison,
  included_environments: [:prod],
  tags: %{
    env: "prod"
  }

config :ret, Ret.Habitat, ip: "127.0.0.1", http_port: 9631

# config :ret, Ret.JanusLoadStatus, default_janus_host: dev_janus_host, janus_port: 443
config :ret, Ret.JanusLoadStatus, default_janus_host: dev_janus_host, janus_port: 4443

config :ret, Ret.RoomAssigner, balancer_weights: [{600, 1}, {300, 50}, {0, 500}]

config :ret, RetWeb.PageController,
  skip_cache: true,
  assets_path: "storage/assets",
  docs_path: "storage/docs"

config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.Meta, phx_host: host

config :ret, Ret.Locking,
  lock_timeout_ms: 1000 * 60 * 15,
  session_lock_db: [
    username: "postgres",
    password: "postgres",
    database: "ret_dev",
    hostname: "localhost"
  ]

config :ret, Ret.Repo.Migrations.AdminSchemaInit, postgrest_password: "password"
config :ret, Ret.StatsJob, node_stats_enabled: false, node_gauges_enabled: false
config :ret, Ret.Coturn, realm: "ret"
