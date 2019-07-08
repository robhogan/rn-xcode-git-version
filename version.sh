# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:

# Add some constant number to the git commit count to make the build number
# Useful for continuing the same project in a new repository
BUILD_OFFSET=0

while getopts "b:" opt; do
    case "$opt" in
    b)  BUILD_OFFSET=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# From http://gabrielrinaldi.me/ios-app-versioning-with-git-tag/

# Update build version with number of commits
BUILD_NUMBER=$(git rev-list HEAD | wc -l | tr -d ' ')

BUILD_NUMBER=$((BUILD_NUMBER+BUILD_OFFSET))

# Set git SHA for this build
GIT_SHA=$(git rev-parse --short HEAD)

# Update version string with build number
LINES_CHANGED=$(git status --porcelain | wc -l | tr -d ' ')
PLIST_CHANGED=$(git status --porcelain | grep "${INFOPLIST_FILE}" | wc -l | tr -d ' ')
if [ "$LINES_CHANGED" == "1" -a "$PLIST_CHANGED" == "1" ]; then
GIT_RELEASE_VERSION=$(git describe --tags --always)
else
GIT_RELEASE_VERSION=$(git describe --tags --always --dirty)
fi

# Allow an rc suffix eg 1.0.0-rc.10 
GIT_RELEASE_VERSION="${GIT_RELEASE_VERSION/%-rc.[0-9]*}"
# Allow a prefix eg appname-1.2.0
GIT_RELEASE_VERSION="${GIT_RELEASE_VERSION/#[a-z]*-}"

#Update plist of build (not of project)
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleShortVersionString" "${GIT_RELEASE_VERSION#*v}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${BUILD_NUMBER}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "GitSHA" "${GIT_SHA}"
