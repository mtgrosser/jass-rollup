module Jass::Rollup::Processor
  VERSION = '1'

  class << self
    
    def cache_key
      @cache_key ||= "#{name}:#{VERSION}".freeze
    end
    
    def call(input)
      data = input[:data]

      code, map = input[:cache].fetch([self.cache_key, data]) do
        result = Jass::Rollup::Compiler.compile(input[:filename])
        [result['code'], nil]
      end

      { data: code }
    end
  
  end
end
