#!/bin/bash

PRODUCT="urigami"

swift build \
  -c release \
  --arch arm64 --arch x86_64 \
  --product $PRODUCT

cp .build/apple/Products/Release/urigami ./urigami
