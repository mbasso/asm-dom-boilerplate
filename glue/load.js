export default config => {
	const isWebAssemblySupported = 'WebAssembly' in window;
	const loader = isWebAssemblySupported
		? import('../dist/wasm/app.js')
		: import('../dist/asmjs/app.asm.js');
	config.locateFile = url => `${isWebAssemblySupported ? 'wasm' : 'asmjs'}/${url}`;

	return loader.then(Module => {
    const app = Module(config);
    delete app.then;
    return app;
  });
};

// Parcel right now doesn't support --reload
// and its HMR is not working on with asm-node, hence hard-reload
if (module.hot) {
	module.hot.accept(function() {
		window.location.reload();
	});
}