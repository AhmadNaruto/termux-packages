TERMUX_PKG_HOMEPAGE=https://rust-analyzer.github.io/
TERMUX_PKG_DESCRIPTION="A Rust compiler front-end for IDEs"
TERMUX_PKG_LICENSE="Apache-2.0, MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE-APACHE, LICENSE-MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2025.08.25"
TERMUX_PKG_SRCURL=https://github.com/rust-lang/rust-analyzer/archive/refs/tags/${TERMUX_PKG_VERSION//./-}.tar.gz
TERMUX_PKG_SHA256=b48823d37f20fd9954c7105a1c0ce30c1a659319c65afa33555c59da5cee46d8
TERMUX_PKG_DEPENDS="rust-src"
TERMUX_PKG_ANTI_BUILD_DEPENDS="rust-src"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

termux_pkg_auto_update() {
	local e=0
	local api_url="https://api.github.com/repos/rust-lang/rust-analyzer/tags"
	local api_url_r=$(curl -s "${api_url}")
	local r1=$(echo "${api_url_r}" | jq -r '.[].name' | sed -nE '/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/p')
	local latest_tag=$(echo "${r1}" | sort -V | tail -n1)
	local latest_version=${latest_tag//-/.}

	if [[ "${latest_version}" == "${TERMUX_PKG_VERSION}" ]]; then
		echo "INFO: No update needed. Already at version '${TERMUX_PKG_VERSION}'."
		return
	fi
	[[ -z "${api_url_r}" ]] && e=1
	[[ -z "${r1}" ]] && e=1
	[[ -z "${latest_tag}" ]] && e=1
	[[ -z "${latest_version}" ]] && e=1

	if [[ "${e}" != 0 ]]; then
		cat <<- EOL >&2
		WARN: Auto update failure!
		api_url_r=${api_url_r}
		r1=${r1}
		latest_tag=${latest_tag}
		latest_version=${latest_version}
		EOL
		return
	fi

	if ! dpkg --compare-versions "${latest_version}" gt "${TERMUX_PKG_VERSION}"; then
		termux_error_exit "
		ERROR: Resulting latest version is not counted as an update!
		Latest version  = ${latest_version}
		Current version = ${TERMUX_PKG_VERSION}
		"
	fi

	termux_pkg_upgrade_version "${latest_version}" --skip-version-check
}

termux_step_pre_configure() {
	termux_setup_rust
}

termux_step_make() {
	export CFG_RELEASE=1
	local rust_flags=(
		"-C opt-level=3"                    # Max performance (use 'z' for smaller size)
		"-C lto=fat"                        # Full LTO - best optimization
		"-C codegen-units=1"                # Single unit - better optimization
		"-C embed-bitcode=yes"              # Enable better LTO
		"-C panic=abort"                    # Remove panic unwinding (~10% smaller)
		"-C strip=symbols"                  # Strip all symbols (~20% smaller)
		"-C link-arg=-Wl,--gc-sections"     # Remove unused code sections
		"-C link-arg=-Wl,--as-needed"       # Only link necessary libraries
		"-C link-arg=-Wl,--strip-all"       # Additional strip (double insurance)
	)

	export RUSTFLAGS="${rust_flags[*]}"

	cargo build \
		--jobs "${TERMUX_PKG_MAKE_PROCESSES}" \
		--target "${CARGO_TARGET_NAME}" \
		--release \
		--locked
}

termux_step_make_install() {
	install -Dm755 -t "${TERMUX_PREFIX}/bin" "target/${CARGO_TARGET_NAME}/release/rust-analyzer"
}
