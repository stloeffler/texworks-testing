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
					return `${folder}/cmake-${version}-win64-x64/bin`;
				case 'linux':
					return `${folder}/cmake-${version}-Linux-x86_64/bin`;
			}
		}();
		core.addPath(pathToCMake);

		console.log(`Adding CMake to path: ${pathToCMake}`);

		if (process.platform === 'win32') {
			await exec.exec('msys2do', ['find', folder.replace(/^([a-zA-Z]):/, '/$1').replace(/\\/g, '/')]);
		} else {
			await exec.exec('find', [folder]);
		}

		core.endGroup();
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
