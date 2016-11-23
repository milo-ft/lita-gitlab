require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require 'active_support/core_ext/string'
require "lita/handlers/gitlab"
