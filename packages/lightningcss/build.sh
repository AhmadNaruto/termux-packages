TERMUX_PKG_HOMEPAGE="https://lightningcss.dev/"
TERMUX_PKG_DESCRIPTION="An extremely fast CSS parser, transformer, bundler, and minifier written in Rust."
TERMUX_PKG_LICENSE="MPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.29.3"
TERMUX_PKG_SRCURL="https://github.com/parcel-bundler/lightningcss/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=ed549ab8d8e53416238e0ff745f9b881f39fbcd07bd70c6d18d35828287c559c
TERMUX_PKG_BUILD_DEPENDS="nodejs, yarn, libnghttp2"
TERMUX_PKG_DEPENDS="libc++, nodejs"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true


termux_step_pre_configure() {
	termux_setup_rust
	termux_setup_nodejs
}

termux_step_make() {
	yarn install --ignore-scripts
	yarn build --release
	strip -x *.node
	cargo build --jobs "${TERMUX_PKG_MAKE_PROCESSES}" --target "${CARGO_TARGET_NAME}" --release --features cli
	ls -a
}

termux_step_make_install() {
	mkdir -p $TERMUX_PREFIX/lib/node_modules/
	# cp -r dist $TERMUX_PREFIX/lib/node_modules/lightningcss/
	mv target/release $TERMUX_PREFIX/lib/node_modules/lightningcss
	cp package.json $TERMUX_PREFIX/lib/node_modules/lightningcss/
	ln -sf $TERMUX_PREFIX/lib/node_modules/lightningcss/lightningcss $TERMUX_PREFIX/bin/lightningcss
	chmod 0700 "$TERMUX_PREFIX/bin/lightningcss"
}
