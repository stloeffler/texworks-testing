#!/bin/sh

cat > bintray.json <<EOF
{
	"package": {
		"name": "auto-upload",
		"repo": "test",
		"subject": "stloeffler"
	},

	"version": {
		"name": "0.1",
		"desc": "This is a version",
		"released": "2016-02-29"
	},
	"files": [{
		"includePattern": "1.txt",
		"uploadPattern": "1.txt"
	}],
	"publish": true
}
EOF
