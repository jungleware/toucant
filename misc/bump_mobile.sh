#!/usr/bin/env bash

BUMP="$1"

CURRENT_VERSION=$(yq -r '.version' mobile/pubspec.yaml)
MAJOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f1)
MINOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f2)
PATCH=$(echo "$CURRENT_VERSION" | cut -d '.' -f3 | cut -d '+' -f1)
VERSION_CODE=$(echo "$CURRENT_VERSION" | cut -d '+' -f2)

echo "Current Version: '$CURRENT_VERSION'"
echo "Major: '$MAJOR'"
echo "Minor: '$MINOR'"
echo "Patch: '$PATCH'"
echo "Version Code: '$VERSION_CODE'"

if [[ $BUMP == "major" ]]; then
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
elif [[ $BUMP == "minor" ]]; then
    MINOR=$((MINOR + 1))
    PATCH=0
elif [[ $BUMP == "patch" ]]; then
    PATCH=$((PATCH + 1))
elif [[ $BUMP == "false" ]]; then
    echo 'Skipping bump'
    echo "TOUCANT_VERSION=v$MAJOR.$MINOR.$PATCH" >> $GITHUB_ENV
    exit 0
else
    echo 'Expected <major|minor|patch|false> as argument'
    exit 1
fi

set $((VERSION_CODE++))

NEXT_VERSION=$MAJOR.$MINOR.$PATCH+$VERSION_CODE
NEXT_VERSION_WITHOUT_CODE=$MAJOR.$MINOR.$PATCH

echo "Bumping Mobile: $CURRENT_VERSION => $NEXT_VERSION"

sed -i "s/^version:.*$/version: $NEXT_VERSION/" mobile/pubspec.yaml

echo "TOUCANT_VERSION=v$NEXT_VERSION_WITHOUT_CODE" >> $GITHUB_ENV

