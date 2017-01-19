use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :napper, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:napper, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
import_config "#{Mix.env}.exs"
