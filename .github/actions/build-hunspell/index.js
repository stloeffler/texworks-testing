const core = require('@actions/core');
const exec = require('@actions/exec');
const tc = require('@actions/tool-cache');

function getUrl(version) {
	const parts = version.split('.');
	const major = parts.length > 0 ? parseInt(parts[0]) : 0;
	const minor = parts.length > 1 ? parseInt(parts[1]) : 0;
	const patch = parts.length > 2 ? parseInt(parts[2]) : 0;

	// Hunspell <= 1.3.3 are on SourceForge, later versions are on GitHub
	if (major === 1 && (minor < 3 || (minor == 3 && patch <= 3))) {
		return `https://downloads.sourceforge.net/project/hunspell/Hunspell/${version}/hunspell-${version}.tar.gz`;
	} else {
		return `https://github.com/hunspell/hunspell/archive/v${version}.tar.gz`
	}
}

async function extract(archivePath) {
	if (process.platform === 'win32') {
		return await tc.extract7z(archivePath);
	}
	else {
		return await tc.extractTar(archivePath);
	}
}

async function run() {
	try {
		const version = core.getInput('version');
		const url = getUrl(version);

		console.log(`Downloading hunspell from ${url}`);

		const archivePath = await tc.downloadTool(url);

		console.log(`Downloaded hunspell to ${archivePath}`);

		const folder = await extract(archivePath) + `/hunspell-${version}`;

		console.log(`Extracted hunspell to ${folder}`);

		await exec.exec('autoreconf', ['-vfi'], {cwd: folder});
		await exec.exec('./configure', {cwd: folder});
		await exec.exec('make -j', {cwd: folder});

        if (core.getInput('install') === 'true') {
	        await exec.exec('sudo make install', {cwd: folder});
        }
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
