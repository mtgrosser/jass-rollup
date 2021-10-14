module Jass
  module Rollup
    class DirectiveProcessor < Sprockets::DirectiveProcessor
      DIRECTIVES = %w[rollup rollup_esm require_npm].freeze
      
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
        directives.select! { |_, name, *args| DIRECTIVES.include?(name) }
        directives.compact!

        data = +""
        data.force_encoding(body.encoding)
        data << header unless header.empty?
        data << process_matching_directives(directives)
        data << body
        # Ensure body ends in a new line
        data << "\n" if data.length > 0 && data[-1] != "\n"

        return data, directives
      end
      
      def process_directives(_); end
      
      def process_matching_directives(directives)
        directives.inject('') do |code, (line_number, name, *args)|
          begin
            code << send("process_#{name}_directive", line_number, *args)
            code << "\n"
          rescue => e
            e.set_backtrace(["#{@filename}:#{line_number}"] + e.backtrace)
            raise e
          end
        end
      end
      
      def process_rollup_esm_directive(line_number, mod)
        Compiler.compile_esm(mod).fetch('code')
      end

      def process_rollup_directive(line_number, entry, *args)
        Compiler.compile_entry(entry).fetch('code')
      end
      
      def process_require_npm_directive(line_number, path, *args)
        File.read(File.expand_path(path, Nodo.modules_root))
      end
    end
  end
end
