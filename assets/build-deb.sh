#!/bin/bash

# fetch newest version number of nghttp2 and spdylay
python3 <<EOF
import urllib.request
import re

def fetch_version(url, app):
	response = urllib.request.urlopen(url)
	html = response.read().decode('utf-8')
	version = re.search('[0-9]\.[0-9]\.[0-9]', html)
	with open('/{0}'.format(app), mode='w') as a_file:
		a_file.write(version.group(0))

fetch_version('http://github.com/tatsuhiro-t/nghttp2/releases', 'nghttp2')
fetch_version('http://github.com/tatsuhiro-t/spdylay/releases', 'spdylay')
EOF

nghttp2_v=`cat /nghttp2`
if [[ ! -f /tmp/nghttp2.deb || "$(dpkg-deb --field /tmp/nghttp2.deb version)" != "$nghttp2_v-1" ]]; then
	apt-get update
	apt-get -y install wget build-essential checkinstall autoconf automake autotools-dev libtool pkg-config zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libevent-dev libjansson-dev libjemalloc-dev cython python3.4-dev
	cd / && wget --no-check-certificate https://github.com/tatsuhiro-t/nghttp2/releases/download/v$nghttp2_v/nghttp2-$nghttp2_v.tar.gz
	tar -zxvf nghttp2-$nghttp2_v.tar.gz && cd nghttp2-$nghttp2_v
	autoreconf -i && automake && autoconf && ./configure && make
	checkinstall -y --requires="libevent-openssl-2.0-5, libevent-2.0-5, libjemalloc-dev" --install=no --maintainer=tatsuhiro-t
	cp /nghttp2-$nghttp2_v/nghttp2_$nghttp2_v-1_amd64.deb /tmp/nghttp2.deb
fi

spdylay_v=`cat /spdylay`
if [[ ! -f /tmp/spdylay.deb || "$(dpkg-deb --field /tmp/spdylay.deb version)" != "$spdylay_v-1" ]]; then
	apt-get update
	apt-get -y install wget build-essential checkinstall autoconf automake autotools-dev libtool pkg-config zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libevent-dev
	cd / && wget --no-check-certificate https://github.com/tatsuhiro-t/spdylay/releases/download/v$spdylay_v/spdylay-$spdylay_v.tar.gz
	tar -zxvf spdylay-$spdylay_v.tar.gz && cd spdylay-$spdylay_v/
	autoreconf -i && automake && autoconf && ./configure && make
	checkinstall -y --requires="libevent-openssl-2.0-5, libevent-2.0-5" --install=no --maintainer=tatsuhiro-t
	cp /spdylay-$spdylay_v/spdylay_$spdylay_v-1_amd64.deb /tmp/spdylay.deb
fi
