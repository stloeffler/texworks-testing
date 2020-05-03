const core = require('@actions/core');
const exec = require('@actions/exec');
const tc = require('@actions/tool-cache');

function extract(archive) {
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
		let url = `https://github.com/hunspell/hunspell/archive/v${version}.tar.gz`;

		console.log(`Downloading hunspell from ${url}`);

		const archivePath = await tc.downloadTool(url);

		console.log(`Downloaded hunspell to ${archivePath}`);

		const folder = extract(archivePath);

		console.log(`Extracted hunspell to ${folder}`);
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
