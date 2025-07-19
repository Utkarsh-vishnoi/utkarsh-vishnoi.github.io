#!/bin/bash

# Create output directory
mkdir -p builds

# Array of operating systems
OPERATING_SYSTEMS=("windows" "linux" "darwin")

# Array of architectures
ARCHITECTURES=("amd64" "arm64")

# Version
VERSION="1.0.0"

echo "🚀 Starting cross-platform build process..."

# Loop through each OS and architecture combination
for os in "${OPERATING_SYSTEMS[@]}"; do
    for arch in "${ARCHITECTURES[@]}"; do
        echo "📦 Building for $os/$arch..."
        
        # Set the output binary name based on OS
        if [ "$os" = "windows" ]; then
            output_name="secure-${VERSION}-${os}-${arch}.exe"
        else
            output_name="secure-${VERSION}-${os}-${arch}"
        fi

        # Execute the build
        GOOS=$os GOARCH=$arch go build -o "builds/${output_name}" secure.go
        
        # Check if build was successful
        if [ $? -eq 0 ]; then
            echo "✅ Successfully built: ${output_name}"
        else
            echo "❌ Failed to build for $os/$arch"
        fi
    done
done

echo "🎉 Build process completed!"
echo "📁 Binaries are located in the 'builds' directory"

# List all generated binaries
echo -e "\n📋 Generated binaries:"
ls -lh builds/
