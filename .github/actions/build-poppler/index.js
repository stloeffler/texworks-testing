const core = require('@actions/core');
const exec = require('@actions/exec');
const io = require('@actions/io');
const tc = require('@actions/tool-cache');

async function extract(archivePath) {
	if (process.platform === 'win32') {
		const tempDirectory = process.env['RUNNER_TEMP'] + 'poppler';
		await io.mkdirP(tempDirectory);
		await io.cp(archivePath, tempDirectory + '/archive.tar.xz')
		await exec.exec('7z', ['x', 'archive.tar.xz'], {'cwd': tempDirectory})
		await exec.exec('7z', ['x', 'archive.tar'], {'cwd': tempDirectory})
		return tempDirectory;
	}
	else {
		return await tc.extractTar(archivePath, null, 'xJ');
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
		const url = `https://poppler.freedesktop.org/poppler-${version}.tar.xz`;

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
					await runCmd('pacman', ['--noconfirm', '-S', 'mingw-w64-x86_64-make', 'mingw-w64-x86_64-gcc', 'mingw-w64-x86_64-freetype'])
					break;
				default:
					break;
			}
			core.endGroup('Installing dependencies');
		}

		console.log(`Downloading poppler from ${url}`);

		const archivePath = await tc.downloadTool(url);

		core.startGroup('Extracting sources');
		const folder = await extract(archivePath) + `/poppler-${version}`;
		const buildDir = folder + '/build';
		core.endGroup();

		core.startGroup('Running CMake');
		await io.mkdirP(buildDir)
		let cmakeArgs = ['-DENABLE_XPDF_HEADERS=ON', '-DENABLE_UNSTABLE_API_ABI_HEADERS=ON', '-DENABLE_LIBOPENJPEG=unmaintained', '-DBUILD_GTK_TESTS=OFF', '-DBUILD_QT4_TESTS=OFF', '-DBUILD_QT5_TESTS=OFF', '-DBUILD_CPP_TESTS=OFF', '-DENABLE_UTILS=OFF', '-DENABLE_CPP=OFF', '-DENABLE_GLIB=OFF'];
		if (process.platform === 'win32') {
//			cmakeArgs.push('-G', 'MSYS Makefiles');
			cmakeArgs.push("-DCMAKE_MAKE_PROGRAM='mingw32-make'")
		}
		cmakeArgs.push(escapePath(folder));
		await runCmd('cmake', cmakeArgs, {cwd: buildDir});
		core.endGroup();

		core.startGroup('Build');
		await runCmd('cmake', ['--build', '.', '--parallel'], {cwd: buildDir});
		core.endGroup();

		if (core.getInput('install') === 'true') {
			core.startGroup('Install');
			if (process.platform === 'linux') {
				await runCmd('sudo', ['cmake', '--build', '.', '--target', 'install'], {cwd: buildDir});
			} else {
				await runCmd('cmake', ['--build', '.', '--target', 'install'], {cwd: buildDir});
			}
			core.endGroup();
		}
	} catch(error) {
		core.setFailed(error.message);
	}
}

run();
