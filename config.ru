require 'rack/codehighlighter'
require './lib/goldfish'

use Rack::Codehighlighter, :coderay, markdown: true,
  element: "code", pattern: /\A:::(\w+)\s*(\n|&#x000A;)/i, logging: false
use Goldfish
run Sinatra::Application
