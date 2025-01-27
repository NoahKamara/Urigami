PUSH=false

for arg in "$@"; do
  if [ "$arg" = "--push" ]; then
    PUSH=true
    break
  fi

  if [ "$arg" = "--help" ]; then
    echo "./release.sh [--push]"
    echo "  --push      push commit to repository"
    exit 0
  fi
done

if [ -z "$VERSION" ]; then
  read -p "VERSION is not set. Please enter a version number: " VERSION
fi

echo "VERSION is set to: $VERSION"

printf "Building $VERSION"
./build.sh || exit 1

# Test Version
TEST_VERSION="$(./urigami --version)"

if [ "v$TEST_VERSION" = "$VERSION" ]; then
  echo "Test OK: 'v$TEST_VERSION'"
else
  echo "Version mismatch 'v$TEST_VERSION' != '$VERSION'"
  exit 1
fi

printf "Compressing"
tar -czf "$VERSION.tar.gz" -C urigami

printf "Creating Tag"
git tag -a "$VERSION" -m "Release $VERSION"

if $PUSH; then
  echo "Pushing Tag $VERION"
  git push origin "$VERSION"

  cd $(brew --repo)/Library/Taps/noahkamara/homebrew-tap || exit 1

  ./release.sh urigami

  git add Formula/urigami.rb
  git commit -m "update(urigami): $VERSION"
  git push origin
fi
