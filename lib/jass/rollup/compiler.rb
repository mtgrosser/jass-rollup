class Jass::Rollup::Compiler < Jass::Core
  require :rollup,
          loadConfigFile: 'rollup/dist/loadConfigFile',
          commonjs: '@rollup/plugin-commonjs', 
          pluginNodeResolve: '@rollup/plugin-node-resolve'

  class << self
    def compile(config)
      instance.compile(config)
    end
  end
  
  def compile(config)
    result = bundle(config)
    result.fetch('output').first.slice('code', 'map')
  end
  
  function :bundle, <<~'JS'
    async (config) => {
      const { options, warnings } = await loadConfigFile(config, { format: 'es' });
      
      warnings.flush();
      
      let inputOptions = options[0];
      let outputOptions = options[0].output[0];
      let inputPlugins = inputOptions.plugins;

      if (inputPlugins && inputPlugins.length == 1 && inputPlugins[0].name == 'stdin') {
        inputPlugins.unshift(commonjs({ requireReturnsDefault: 'namespace',  defaultIsModuleExports: true }));
        inputPlugins.unshift(pluginNodeResolve.nodeResolve());
      }

      const bundle = await rollup.rollup(inputOptions);
      return await bundle.generate(outputOptions);
    }
  JS

end
