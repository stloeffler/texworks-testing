import json, urllib.request

print('Fetching active Ubuntu series')
with urllib.request.urlopen('https://api.launchpad.net/1.0/ubuntu/series') as www:
	dat = json.loads(www.read())
SERIES = ' '.join([e['name'] for e in dat['entries'] if e['active']])

print('   {0}'.format(SERIES))
print('::set-output name=SERIES:"{0}"'.format(SERIES))
