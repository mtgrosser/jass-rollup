class Jass::Rollup::Compiler < Nodo::Core
  require :rollup,
          loadConfigFile: 'rollup/dist/loadConfigFile',
          virtual: '@rollup/plugin-virtual',
          commonjs: '@rollup/plugin-commonjs', 
          nodeResolve: '@rollup/plugin-node-resolve'

  def compile(config)
    result = bundle(config)
    result.fetch('output').first.slice('code', 'map')
  end
  class_function :compile
  
  def compile_esm(import, export = nil)
    export ||= import
    result = bundle_esm(import, export)
    result.fetch('output').first.slice('code', 'map')
  end
  class_function :compile_esm
  
  function :bundle_esm, <<~'JS'
    async (mod, name) => {
      const code = `import * as ${name} from "${mod}"; export default ${name};`;
      const inputOptions = {
        input: '__jass_entry__',
        plugins: [
          nodeResolve.nodeResolve({ moduleDirectories: [process.env.NODE_PATH] }),
          virtual({ __jass_entry__: code }),
          commonjs({ requireReturnsDefault: 'namespace', defaultIsModuleExports: true })
        ]
      };
      const outputOptions = {
        format: 'es',
        exports: 'named'
      };
      const bundle = await rollup.rollup(inputOptions);
      return await bundle.generate(outputOptions);
    }
  JS
  
  function :bundle, <<~'JS'
    async (config) => {
      const { options, warnings } = await loadConfigFile(config, { format: 'es' });
      
      warnings.flush();
      
      let inputOptions = options[0];
      let outputOptions = options[0].output[0];
      let inputPlugins = inputOptions.plugins;

      if (inputPlugins && inputPlugins.length == 1 && inputPlugins[0].name == 'stdin') {
        inputPlugins.unshift(commonjs({ requireReturnsDefault: 'namespace',  defaultIsModuleExports: true }));
        inputPlugins.unshift(nodeResolve.nodeResolve({ moduleDirectories: [process.env.NODE_PATH] }));
      }

      const bundle = await rollup.rollup(inputOptions);
      return await bundle.generate(outputOptions);
    }
  JS

end
