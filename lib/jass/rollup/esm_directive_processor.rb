module Jass
  module Rollup
    class EsmDirectiveProcessor < Sprockets::DirectiveProcessor
=begin  
      def _call(input)
        @environment  = input[:environment]
        @uri          = input[:uri]
        @filename     = input[:filename]
        @dirname      = File.dirname(@filename)
        # If loading a source map file like `application.js.map` resolve
        # dependencies using `.js` instead of `.js.map`
        @content_type = Sprockets::SourceMapProcessor.original_content_type(input[:content_type], error_when_not_found: false)
        @required     = Set.new(input[:metadata][:required])
        @stubbed      = Set.new(input[:metadata][:stubbed])
        @links        = Set.new(input[:metadata][:links])
        @dependencies = Set.new(input[:metadata][:dependencies])
        @to_link      = Set.new
        @to_load      = Set.new
  
        data, directives = process_source(input[:data])
        process_directives(directives)

        {
          data:         data,
          required:     @required,
          stubbed:      @stubbed,
          links:        @links,
          to_load:      @to_load,
          to_link:      @to_link,
          dependencies: @dependencies
        }
      end
=end

      def process_source(source)
        header = source[@header_pattern, 0] || ""
        body   = $' || source

        header, directives = extract_directives(header)
        directives.map! { |_, name, import, export = nil| [import, export] if name == 'esm' }
        directives.compact!

        data = +""
        data.force_encoding(body.encoding)
        data << header unless header.empty?
        data << process_esm_directives(directives)
        data << body
        # Ensure body ends in a new line
        data << "\n" if data.length > 0 && data[-1] != "\n"

        return data, directives
      end
      
      def process_directives(_); end
      
      def process_esm_directives(directives)
        directives.map { |import, export| Compiler.compile_esm(import, export).fetch('code') }.join("\n")
      end

      def process_esm_directive(path, *args)
        # do nothing
      end
    end
  end
end
