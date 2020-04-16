import os.path, subprocess, urllib.request

POPPLER_VERSION='0.87.0'
POPPLER_FOLDER='poppler-{0}'.format(POPPLER_VERSION)
POPPLER_FILENAME='poppler-{0}.tar.xz'.format(POPPLER_VERSION)
POPPLER_URL='https://poppler.freedesktop.org/{0}'.format(POPPLER_FILENAME)

def downloadFile(filename, url):
	with open(filename, 'wb') as fout:
		with urllib.request.urlopen(url) as fin:
			fout.write(fin.read())

def echo_and_run(args, **kwargs):
	print(' '.join(args))
	subprocess.run(args, **kwargs)

downloadFile(POPPLER_FILENAME, POPPLER_URL)
# FIXME: Check checksum

echo_and_run(['7z', 'x', POPPLER_FILENAME])
echo_and_run(['7z', 'x', os.path.splitext(POPPLER_FILENAME)[0]])
echo_and_run(['cmake', '-B', 'build', '.'], cwd = POPPLER_FOLDER)
echo_and_run(['cmake', '--build', 'build'], cwd = POPPLER_FOLDER)
echo_and_run(['cmake', '--install', 'build'], cwd = POPPLER_FOLDER)
