require 'nodo'

require_relative 'rollup/version'
require_relative 'rollup/compiler'
require_relative 'rollup/processor'

if defined?(Sprockets) and Sprockets.respond_to?(:register_transformer)
  Sprockets.register_mime_type 'application/javascript+rollup-config', extensions: %w[.js.rollup .rollup], charset: :unicode
  Sprockets.register_transformer 'application/javascript+rollup-config', 'application/javascript', Jass::Rollup::Processor
end
