# From http://gabrielrinaldi.me/ios-app-versioning-with-git-tag/

# Update build version with number of commits
BUILD_NUMBER=$(git rev-list HEAD | wc -l | tr -d ' ')

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

#Update plist of build (not of project)
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleShortVersionString" "${GIT_RELEASE_VERSION#*v}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${BUILD_NUMBER}"
defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "GitSHA" "${GIT_SHA}"
