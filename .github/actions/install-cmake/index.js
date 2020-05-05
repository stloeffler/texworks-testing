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
		const fullname = function() {
			switch (process.platform) {
				case 'darwin':
					return `cmake-${version}-Darwin-x86_64`;
				case 'win32':
					return `cmake-${version}-win64-x64`;
				case 'linux':
				default:
					return `cmake-${version}-Linux-x86_64`;
			}
		}();
		const archive = function() {
			switch (process.platform) {
				case 'win32':
					return `${fullname}.zip`;
				default:
					return `${fullname}.tar.gz`;
			}
		}();
		const url = `https://github.com/Kitware/CMake/releases/download/v${version}/${archive}`;

		console.log(`Downloading CMake from ${url}`);
		const archivePath = await tc.downloadTool(url);

		core.startGroup('Extracting');
		const folder = await extract(archivePath);
		core.addPath(`${folder}/${fullname}/bin`);

		console.log(`Adding CMake to path: ${folder}/${fullname}/bin`);

		if (process.platform === 'win32') {
			await exec.exec('msys2do', ['find', folder]);
		} else {
			await exec.exec('find', [folder]);
		}

		core.endGroup();
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
