#!/bin/bash
# NOTE:  JSON pretty print requires nodejs be installed

TMPFILE=/tmp/service-list.json
curl http://192.168.122.138:8500/v1/agent/services > $TMPFILE
node -e "console.log(JSON.stringify(JSON.parse(require('fs') \
	      .readFileSync(process.argv[1])), null, 4));"  $TMPFILE

