require 'nodo'

require_relative 'rollup/version'
require_relative 'rollup/compiler'

begin
  require 'sprockets'
  
  require_relative 'rollup/processor'
  require_relative 'rollup/esm_directive_processor'
  
  Sprockets.register_mime_type 'application/javascript+rollup-config', extensions: %w[.js.rollup .rollup], charset: :unicode
  Sprockets.register_transformer 'application/javascript+rollup-config', 'application/javascript', Jass::Rollup::Processor
  Sprockets.register_preprocessor 'application/javascript', Jass::Rollup::EsmDirectiveProcessor.new(comments: ['//', ['/*', '*/']])
rescue LoadError
  # Sprockets not available
end
