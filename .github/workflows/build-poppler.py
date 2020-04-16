import os, subprocess, urllib.request

POPPLER_VERSION='0.87.0'
POPPLER_FOLDER='poppler-{0}'.format(POPPLER_VERSION)
POPPLER_FILENAME='poppler-{0}.tar.xz'.format(POPPLER_VERSION)
POPPLER_URL='https://poppler.freedesktop.org/{0}'.format(POPPLER_FILENAME)

OPENJPEG_VERSION = '2.3.1'
OPENJPEG_CMAKE_DIR = os.path.join(os.environ.get('VCPKG_INSTALLATION_ROOT'), 'packages', 'openjpeg-v{0}-windows-x64'.format(OPENJPEG_VERSION), 'lib', 'openjpeg-2.3')
OPENJPEG_FILENAME = 'openjpeg-v{0}-windows-x64.zip'.format(OPENJPEG_VERSION)
OPENJPEG_URL = 'https://github.com/uclouvain/openjpeg/releases/download/v{0}/{1}'.format(OPENJPEG_VERSION, OPENJPEG_FILENAME)

def downloadFile(filename, url):
	with open(filename, 'wb') as fout:
		with urllib.request.urlopen(url) as fin:
			fout.write(fin.read())

def echo_and_run(args, **kwargs):
	print(' '.join(args))
	subprocess.run(args, **kwargs).check_returncode()

downloadFile(OPENJPEG_FILENAME, OPENJPEG_URL)
echo_and_run(['unzip', '-d', os.path.join(os.environ.get('VCPKG_INSTALLATION_ROOT'), 'packages'), OPENJPEG_FILENAME])

downloadFile(POPPLER_FILENAME, POPPLER_URL)
# FIXME: Check checksum
echo_and_run(['7z', 'x', POPPLER_FILENAME])
echo_and_run(['7z', 'x', os.path.splitext(POPPLER_FILENAME)[0]])
echo_and_run(['patch', '-p1', '-i', os.path.join(os.environ.get('GITHUB_WORKSPACE'), '.github', 'workflows', 'poppler.patch')], cwd = os.path.join(POPPLER_FOLDER))

echo_and_run(['cmake', '-B', 'build', '-DOpenJPEG_DIR={0}'.format(OPENJPEG_CMAKE_DIR), '-DCMAKE_TOOLCHAIN_FILE={0}'.format(os.path.join(os.environ.get('VCPKG_INSTALLATION_ROOT'), 'scripts/buildsystems/vcpkg.cmake')), '-DENABLE_CPP=OFF', '-DCMAKE_BUILD_TYPE=Release',  '.'], cwd = POPPLER_FOLDER)
echo_and_run(['cmake', '--build', 'build'], cwd = POPPLER_FOLDER)
echo_and_run(['cmake', '--install', 'build'], cwd = POPPLER_FOLDER)
