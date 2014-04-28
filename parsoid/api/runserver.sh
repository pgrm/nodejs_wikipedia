#!/bin/sh
# Wrapper for Parsoid web service (server.js and ParserService.js)

# redirect port 80 to unprivileged port 8000
if ! `iptables -tnat -L | grep -q 'tcp dpt:http redir ports 8000'`;then
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8000
fi

if [ "$1" = "--testing" ]; then
    echo "Cloning git repo for testing purposes...."
    chown -R nobody testing-repos
    cd testing-repos
    rm -rf master
    sudo -u nobody git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Parsoid.git master 2>&1 > /dev/null
    cd master/js
    npm install
fi

# update the source
git pull

# kill a running server (crude version..)
killall -9 node

# run the server as non-privileged user
nohup sudo -u nobody node server.js >> nohup.out 2>&1 &
