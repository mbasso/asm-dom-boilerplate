export default config => 
  import('../dist/wasm/app.js').then(Module => {
    config.locateFile = url =>
      (process.env.NODE_ENV === 'development' ? 'dist/' : '') + 'wasm/' + url;
    const app = Module(config);
    delete app.then;
    return app;
  });
