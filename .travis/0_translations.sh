#!/bin/bash
echo "Testing translations..."
echo ""

for translationFilePath in res/values/*; do
  echo ""
  echo ""

  # Ensure that the file is, in fact, a .arb file.
  if [[ $translationFilePath != *.arb ]]; then
    continue
  fi

  # Ignore strings_en_GB.arb.
  if [[ $translationFilePath == *_en_GB.arb ]]; then
    continue
  fi

  # Get just the path.
  translationFile="${translationFilePath/res\/values\//}"
  processOutput=$((node ./.travis/utils/testTranslations.js $translationFile) 2>&1)

  status=$?
  if [[ $status -eq 0 ]]; then
    echo "$translationFile [PASS]"
  else
    echo "$translationFile [FAIL]"
    echo "$processOutput"
  fi
done
