TERMUX_PKG_HOMEPAGE=https://github.com/oxalica/nil.git
TERMUX_PKG_DESCRIPTION="NIx Language server, an incremental analysis assistant for writing in Nix."
TERMUX_PKG_LICENSE="Apache-2, MIT"
TERMUX_PKG_MAINTAINER="@AhmadNaruto"
TERMUX_PKG_VERSION="2025.06.13"
TERMUX_PKG_SRCURL="https://github.com/oxalica/nil/archive/refs/tags/${TERMUX_PKG_VERSION//./-}.tar.gz"
TERMUX_PKG_SHA256=8c4123717827d6e386925a40bacfeb9ee9bc619c6a09edf92c20582ad2d09663
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXCLUDED_ARCHES="arm, i686"

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	cargo build --jobs $TERMUX_PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release  --locked
}

termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/nil
}
