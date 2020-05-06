const core = require('@actions/core');
const tc = require('@actions/tool-cache');
const exec = require('@actions/exec');

async function extract(archive) {
	if (process.platform === 'win32') {
		return await tc.extractZip(archive);
	} else {
		return await tc.extractTar(archive);
	}
}

async function run() {
	try {
		const version = core.getInput('version');
		const archive = function() {
			switch (process.platform) {
				case 'darwin':
					return `cmake-${version}-Darwin-x86_64.tar.gz`;
				case 'win32':
					return `cmake-${version}-win64-x64.zip`;
				case 'linux':
					return `cmake-${version}-Linux-x86_64.tar.gz`;
			}
		}();
		const url = `https://github.com/Kitware/CMake/releases/download/v${version}/${archive}`;

		console.log(`Downloading CMake from ${url}`);
		const archivePath = await tc.downloadTool(url);

		core.startGroup('Extracting');
		const folder = await extract(archivePath);
		const pathToCMake = function() {
			switch (process.platform) {
				case 'darwin':
					return `${folder}/cmake-${version}-Darwin-x86_64/CMake.app/Contents/bin`;
				case 'win32':
					return `${folder}/cmake-${version}-win64-x64/bin`.replace(/^([a-zA-Z]):/, '/$1').replace(/\\/g, '/');
				case 'linux':
					return `${folder}/cmake-${version}-Linux-x86_64/bin`;
			}
		}();
		if (process.platform === 'win32') {
			// I have found no way so far to easily & reliably modify the msys
			// $PATH, so we just move everything into /usr/local (which is in
			// the $PATH automatically)
			const path = `${folder}/cmake-${version}-win64-x64`.replace(/^([a-zA-Z]):/, '/$1').replace(/\\/g, '/');
			await exec.exec('msys2do', ['mv', `${path}/*`, '/usr/local'])
		} else {
			core.addPath(pathToCMake);
		}
		core.endGroup();
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
