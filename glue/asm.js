export default config => 
  import('../dist/asmjs/app.asm.js').then(Module => {
    config.locateFile = url =>
      (process.env.NODE_ENV === 'development' ? 'dist/' : '') + 'asmjs/' + url;
    const app = Module(config);
    delete app.then;
    return app;
  });
