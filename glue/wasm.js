export default config => 
  import('../dist/wasm/app.js').then(Module => {
    config.locateFile = url => `wasm/${url}`;
    const app = Module(config);
    delete app.then;
    return app;
  });

// Parcel right now doesn't support --reload
// and its HMR is not working on with asm-node, hence hard-reload
if (module.hot) {
	module.hot.accept(function() {
		window.location.reload();
	});
}