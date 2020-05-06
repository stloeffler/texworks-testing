const core = require('@actions/core');
const exec = require('@actions/exec');
const io = require('@actions/io');
const tc = require('@actions/tool-cache');

async function extract(archivePath, suffix) {
	if (process.platform === 'win32') {
		const tempDirectory = process.env['RUNNER_TEMP'] + '/' + suffix;
		await io.mkdirP(tempDirectory);
		await io.cp(archivePath, tempDirectory + '/archive.tar.xz')
		await exec.exec('7z', ['x', 'archive.tar.xz'], {'cwd': tempDirectory})
		await exec.exec('7z', ['x', 'archive.tar'], {'cwd': tempDirectory})
		return tempDirectory;
	}
	else {
		return await tc.extractTar(archivePath, null, 'x');
	}
}

async function runCmd(cmd, args, opts) {
	if (process.platform === 'win32') {
		return await exec.exec('msys2do', [cmd].concat(args), opts);
	} else {
		return await exec.exec(cmd, args, opts);
	}
}

function escapePath(path) {
	if (process.platform === 'win32') {
		return path.replace(/^([a-zA-Z]):/, "/$1").replace(/\\/g, '/');
	} else {
		return path;
	}
}

async function run() {
	try {
		const version = core.getInput('version');
		const popplerData = core.getInput('poppler-data-version');
		const url = `https://poppler.freedesktop.org/poppler-${version}.tar.xz`;
		const tempDir = process.env['RUNNER_TEMP'].replace(/^([a-zA-Z]):/, '/$1').replace(/\\/g, '/');

		if (core.getInput('install-deps') === 'true') {
			core.startGroup('Installing dependencies');
			switch (process.platform) {
				case 'linux':
					break;
				case 'darwin':
					await runCmd('brew', ['install', 'gobject-introspection', 'pkg-config', 'cairo', 'fontconfig', 'freetype', 'gettext', 'glib', 'jpeg', 'libpng', 'libtiff', 'little-cms2']);
//					await runCmd('brew', ['list', 'nss']);
					await runCmd('ls', ['/usr/local/lib']);
					break;
				case 'win32':
					await runCmd('pacman', ['--noconfirm', '-S', 'make', 'mingw-w64-x86_64-gcc', 'mingw-w64-x86_64-freetype', 'mingw-w64-x86_64-libjpeg-turbo'])
					break;
				default:
					break;
			}
			core.endGroup('Installing dependencies');
		}

		console.log(`Downloading poppler from ${url}`);

		const archivePath = await tc.downloadTool(url);

		core.startGroup('Extracting sources');
		const folder = await extract(archivePath, 'poppler') + `/poppler-${version}`;
		const buildDir = folder + '/build';
		core.endGroup();

		core.startGroup('Running CMake');
		await io.mkdirP(buildDir)
		let cmakeArgs = ['-DENABLE_XPDF_HEADERS=ON', '-DENABLE_UNSTABLE_API_ABI_HEADERS=ON', 'ENABLE_XPDF_HEADERS=ON', '-DENABLE_LIBOPENJPEG=unmaintained', '-DBUILD_GTK_TESTS=OFF', '-DBUILD_QT4_TESTS=OFF', '-DBUILD_QT5_TESTS=OFF', '-DBUILD_CPP_TESTS=OFF', '-DENABLE_UTILS=OFF', '-DENABLE_CPP=OFF', '-DENABLE_GLIB=OFF'];
		let cmakeOpts = {cwd: buildDir};
		if (process.platform === 'win32') {
			cmakeArgs.push('-G', '\\"MSYS Makefiles\\"');
			cmakeArgs.push(`-DCMAKE_INSTALL_PREFIX=${tempDir}/msys/msys64/mingw64`);
//			cmakeArgs.push("-DCMAKE_MAKE_PROGRAM='mingw32-make'")
			cmakeOpts.windowsVerbatimArguments = true;
		}
		cmakeArgs.push(escapePath(folder));
		await runCmd('cmake', cmakeArgs, cmakeOpts);
		core.endGroup();

		core.startGroup('Build');
		await runCmd('make', ['-j'], {cwd: buildDir});
		core.endGroup();

		if (core.getInput('install') === 'true') {
			core.startGroup('Install');
			if (process.platform === 'linux') {
				await runCmd('sudo', ['make', 'install'], {cwd: buildDir});
			} else {
				await runCmd('make', ['install'], {cwd: buildDir});
			}
			core.endGroup();
		}

		if (popplerData !== 'undefined') {
			const url = `https://poppler.freedesktop.org/poppler-data-${popplerData}.tar.gz`;

			console.log(`Downloading poppler-data from ${url}`);

			const archivePath = await tc.downloadTool(url);

			core.startGroup('Extracting poppler-data');
			const folder = await extract(archivePath, 'poppler-data') + `/poppler-data-${popplerData}`;
			core.endGroup();
			core.startGroup('Installing poppler-data');
			if (process.platform === 'linux') {
				await runCmd('sudo', ['make', 'install'], {cwd: folder});
			} else if (process.platform === 'win32') {
				await runCmd('make', [`prefix=${tempDir}/msys/msys64/mingw64`, 'install'], {cwd: folder});
			} else {
				await runCmd('make', ['install'], {cwd: folder});
			}
			core.endGroup();
		}
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
