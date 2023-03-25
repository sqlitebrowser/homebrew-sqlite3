#!/bin/sh
export SQLITEFTS5_PATH=$GITHUB_WORKSPACE/Formula/sqlitefts5.rb
export SQLITE_TARBALL=$(curl -s https://sqlite.org/download.html | awk '/<!--/,/-->/ {print}' | grep 'sqlite-autoconf' | cut -d ',' -f 3)
export SQLITE_TARBALL=https://sqlite.org/${SQLITE_TARBALL}
curl -LsS -o sqlite.tar.gz ${SQLITE_TARBALL}
export SHA256SUM=$(sha256sum sqlite.tar.gz | awk '{print $1}')
export VERSION=$(curl -s https://sqlite.org/download.html | awk '/<!--/,/-->/ {print}' | grep 'sqlite-autoconf' | cut -d ',' -f 2)

export CURRENT_VERSION=$(grep -o 'version "\S*"' ${SQLITEFTS5_PATH} | awk '{print $2}' | tr -d '"')
if [ "$VERSION" = "$CURRENT_VERSION" ]; then
    echo "No new version available"
else
    sed -i '0,/url "/s|url "\(.*\)"|url "'${SQLITE_TARBALL}'"|' ${SQLITEFTS5_PATH}
    sed -i "s/version \"[^\"]*\"/version \"${VERSION}\"/" ${SQLITEFTS5_PATH}
    sed -i "s/sha256 \"[^\"]*\"/sha256 \"${SHA256SUM}\"/" ${SQLITEFTS5_PATH}
    export IS_SQLITE_UPDATED=1
fi

