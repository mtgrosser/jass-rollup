class Jass::Rollup::ESM::Compiler < Jass::Core
  dependency rollup: 'rollup'
  dependency commonjs: '@rollup/plugin-commonjs'
  dependency pluginNodeResolve: '@rollup/plugin-node-resolve'

  class << self
    def instance
      @instance ||= new
    end
    
    def compile(source_path, filename)
      instance.compile(source, filename)
    end
  end
  
  def compile(entry, input: {}, output: {})
    print "bundle(#{entry}) ... #{Thread.current}"
    bundle(entry, input, output)
  end
  
  function :bundle, <<~'JS'
    (entry, inputOptions, outputOptions) => {
      inputOptions = inputOptions || {};
      outputOptions = outputOptions || {}
      Object.assign(inputOptions, { input: entry });
      Object.assign(outputOptions, { format: 'es', plugins: [pluginNodeResolve.nodeResolve(), commonjs()] });
      var promise = rollup.rollup(inputOptions).then(bundle => bundle.generate(outputOptions));
      return promise;
    }
  JS
end
