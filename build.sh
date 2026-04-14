#!/bin/bash

# build.sh - Build StashFlow for all available platforms

# Set up colors for logging
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting StashFlow Build Process...${NC}"

# 1. Fetch dependencies
echo -e "${YELLOW}Fetching dependencies...${NC}"
flutter pub get || { echo -e "${RED}flutter pub get failed!${NC}"; exit 1; }

# 2. Run code generation (for graphql_codegen, freezed, etc.)
echo -e "${YELLOW}Running code generation...${NC}"
dart run build_runner build --delete-conflicting-outputs || { echo -e "${RED}Code generation failed!${NC}"; exit 1; }

# Function to build a platform and handle errors (try/except logic)
build_platform() {
    local platform=$1
    local command=$2
    
    echo -e "${YELLOW}Attempting to build for ${platform}...${NC}"
    
    # Check if the build command succeeded
    if eval "$command"; then
        echo -e "${GREEN}SUCCESS: ${platform} build completed.${NC}"
        return 0
    else
        echo -e "${RED}SKIPPED/FAILED: ${platform} build was not successful or is unavailable on this system.${NC}"
        return 1
    fi
}

# 3. Build Platforms
# We use a list of platforms and their build commands.
# The user specifically requested to ignore unavailable platforms.

declare -A platforms
platforms["Android (APK)"]="flutter build apk --release --split-per-abi"
platforms["Web"]="flutter build web --release"
platforms["Linux"]="flutter build linux --release"
platforms["Windows"]="flutter build windows --release"
platforms["macOS"]="flutter build macos --release"

results=""

for platform in "Android (APK)" "Web" "Linux" "Windows" "macOS"; do
    if build_platform "$platform" "${platforms[$platform]}"; then
        results="${results}${GREEN}[✓] ${platform}${NC}\n"
    else
        results="${results}${RED}[✗] ${platform}${NC}\n"
    fi
done

# 4. Summary
echo -e "\n${YELLOW}=== Build Summary ===${NC}"
echo -e "$results"

echo -e "${YELLOW}Build process finished.${NC}"
