#!/bin/bash
#
# janus-gateway Project-Native Self-Check Tool
#
# This script combines the functionality of shfmt, bashate, and shellcheck
# to provide a comprehensive quality gate for all shell scripts in this project.
# It builds all tools from source to ensure a secure, self-contained toolchain.

set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # The return value of a pipeline is the status of the last command to exit with a non-zero status.

# --- STAGE 1: TOOLCHAIN INSTALLATION ---
#
# This section checks for the required binaries in a local bin directory.
# If a tool is not found, it is cloned and built from source.
#
# Dependencies for this script:
# - git
# - go (for shfmt)
# - cabal-install (for shellcheck)
# - python3 and python3-venv (for bashate)

BIN_DIR="$(pwd)/ci/bin"
TOOLS_SRC_DIR="$(pwd)/ci/tools_src"
PATH="$BIN_DIR:$PATH" # Prepend our local bin to the PATH

echo "--- Initializing Toolchain ---"
mkdir -p "$BIN_DIR"
mkdir -p "$TOOLS_SRC_DIR"

# Tool: shellcheck (Haskell)
if [ ! -x "$BIN_DIR/shellcheck" ]; then
    echo "-> shellcheck not found. Building from source..."
    if ! command -v cabal &> /dev/null; then
        echo "Error: 'cabal' (Haskell build tool) is not installed. Please install it." >&2
        exit 1
    fi
    git clone --depth 1 https://github.com/koalaman/shellcheck.git "$TOOLS_SRC_DIR/shellcheck"
    (
        cd "$TOOLS_SRC_DIR/shellcheck"
        cabal update
        cabal v2-install --installdir="$BIN_DIR" --overwrite-policy=always
    )
    echo "-> shellcheck installed successfully."
fi

# Tool: shfmt (Go)
if [ ! -x "$BIN_DIR/shfmt" ]; then
    echo "-> shfmt not found. Building from source..."
    if ! command -v go &> /dev/null; then
        echo "Error: 'go' (Go compiler) is not installed. Please install it." >&2
        exit 1
    fi
    git clone --depth 1 https://github.com/mvdan/sh.git "$TOOLS_SRC_DIR/sh"
    (
        cd "$TOOLS_SRC_DIR/sh"
        go build -o "$BIN_DIR/shfmt" ./cmd/shfmt
    )
    echo "-> shfmt installed successfully."
fi

# Tool: bashate (Python)
if [ ! -x "$BIN_DIR/bashate" ]; then
    echo "-> bashate not found. Setting up from source..."
    if ! command -v python3 &> /dev/null; then
        echo "Error: 'python3' is not installed. Please install it." >&2
        exit 1
    fi
    git clone --depth 1 https://github.com/openstack/bashate.git "$TOOLS_SRC_DIR/bashate"
    python3 -m venv "$TOOLS_SRC_DIR/bashate/.venv"
    # Activate venv, install package, then deactivate
    source "$TOOLS_SRC_DIR/bashate/.venv/bin/activate"
    pip3 install "$TOOLS_SRC_DIR/bashate"
    deactivate

    # Create a wrapper script to execute bashate from its venv
    echo '#!/bin/bash' > "$BIN_DIR/bashate"
    echo "set -e" >> "$BIN_DIR/bashate"
    echo "\"$TOOLS_SRC_DIR/bashate/.venv/bin/bashate\" \"\$@\"" >> "$BIN_DIR/bashate"
    chmod +x "$BIN_DIR/bashate"
    echo "-> bashate installed successfully."
fi

echo "--- Toolchain is ready ---"

# --- STAGE 2: LINTING AND FORMATTING ---
#
# This section iterates through all .sh files in the scripts/ directory
# and runs them through our compiled linting and formatting tools.

echo "--- Running Quality Checks ---"

# Find all shell scripts and store them in an array
readarray -d '' scripts_to_check < <(find scripts -name "*.sh" -print0)

if [ ${#scripts_to_check[@]} -eq 0 ]; then
    echo "No shell scripts found to check. Exiting."
    exit 0
fi

echo "Found ${#scripts_to_check[@]} script(s) to check."

for script in "${scripts_to_check[@]}"; do
    echo -e "\n=> Checking '$script'..."

    # Check 1: Formatting (shfmt)
    # The '-d' flag will show a diff of changes needed. If there are changes,
    # the command will exit with an error code, failing the build.
    echo "   -> Checking formatting with shfmt..."
    shfmt -i 4 -d "$script"

    # Check 2: Style (bashate)
    # The '-i E006' ignores a specific rule that often conflicts with shfmt.
    # We add more ignores as needed.
    echo "   -> Checking style with bashate..."
    bashate -i E006 "$script"

    # Check 3: Bug Detection (shellcheck)
    # We use a set of common ignores. Adjust as needed for project style.
    echo "   -> Checking for bugs with shellcheck..."
    shellcheck \
        -e SC2034,SC2154,SC1091 \
        "$script"

    echo "   -> PASS: '$script' passed all checks."
done

# --- STAGE 3: RESULT AGGREGATION ---
#
# The script is designed with 'set -e', so any failure in the linting stage
# will cause the script to exit with an error code, which will fail the CI job.
# A final success message is printed here if all scripts passed all checks.
#

echo -e "\n--- SUMMARY ---"
echo "✅ All ${#scripts_to_check[@]} shell scripts passed all quality checks."
