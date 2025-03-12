#!/bin/bash

. bin/config.inc

doc=$1
url=$doc

if ! echo "$url" | grep 'http://' > /dev/null; then # si pas d'http dans le doc, on construit à partir de config.inc
    url="http://$COUCHDBDOMAIN:$COUCHDBPORT/$COUCHDBBASE/$doc"
else # on récupère la dernière partie de l'url
    doc=${doc##*/}
fi

i=0
mkdir  -p couchdbdoc2git && cd couchdbdoc2git && rm -rf .git/* && rm -f -- * && git init .
curl -s --header 'Accept: application/json' "$url?open_revs=all&revs=true" | jq .[0].ok._revisions.ids.[] > .revisions.json

tac .revisions.json | awk -F '"' '{print $2}' | while read -r rev ; do
	i=$(( i + 1 ))
	echo "$i-$rev"
	curl -s "$url?rev=$i-$rev" | jq . > "$doc.json"
	git add "$doc.json"
	git commit -m "version $i-$rev"
done

git log -p "$doc.json"
