use Mix.Config

config :logman,
  port: String.to_integer(System.get_env("PORT") || "5555"),
  node_id: System.get_env("NODE_ID")
