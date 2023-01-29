#!/bin/bash

set +e

echo " ---------------------------------------------"
echo running gitleaks "$(gitleaks version)"
echo " ---------------------------------------------"
echo "Setting Git safe directory (CVE-2022-24765)"
echo "git config --global --add safe.directory ${GITHUB_WORKSPACE}"
git config --global --add safe.directory "${GITHUB_WORKSPACE}"
echo " ---------------------------------------------"

echo " ---------------------------------------------"
echo "Running Gitleaks with the following arguments"
echo "----------------------------------------------"
echo "Source: $INPUT_SOURCE"
echo "Config: $INPUT_CONFIG"
echo "Report Format: $INPUT_REPORT_FORMAT"
echo "Report Path: $INPUT_REPORT_PATH"
echo "No Git: $INPUT_NO_GIT"
echo "Redact: $INPUT_REDACT"
echo "Exit Code: $INPUT_EXIT_CODE"
echo "Verbose: $INPUT_VERBOSE"
echo "Log Level: $INPUT_LOG_LEVEL"
echo "----------------------------------------------"

# If the event is a push or a PR, check only those commits that differ from the base branch
# Any other event, check the whole repository (intended for manual or scheduled runs)
if [[ "$GITHUB_EVENT_NAME" = "push" ]] || [[ "$GITHUB_EVENT_NAME" = "pull_request" ]]
then
  # Print the command that will be executed
  echo "gitleaks detect\
    --source=$INPUT_SOURCE \
    --config=$INPUT_CONFIG \
    --report-format=$INPUT_REPORT_FORMAT \
    --report-path=$INPUT_REPORT_PATH \
    --no-git=$INPUT_NO_GIT \
    --redact=$INPUT_REDACT \
    --exit-code=$INPUT_EXIT_CODE \
    --verbose=$INPUT_VERBOSE \
    --log-level=$INPUT_LOG_LEVEL \
    --log-opts=--left-right --cherry-pick remotes/origin/$GITHUB_BASE_REF...remotes/origin/$GITHUB_HEAD_REF"

  # Execute the command
  gitleaks detect \
    --source="$INPUT_SOURCE" \
    --config="$INPUT_CONFIG" \
    --report-format="$INPUT_REPORT_FORMAT" \
    --report-path="$INPUT_REPORT_PATH" \
    --no-git="$INPUT_NO_GIT" \
    --redact="$INPUT_REDACT" \
    --exit-code="$INPUT_EXIT_CODE" \
    --verbose="$INPUT_VERBOSE" \
    --log-level="$INPUT_LOG_LEVEL" \
    --log-opts="--left-right --cherry-pick remotes/origin/$GITHUB_BASE_REF...remotes/origin/$GITHUB_HEAD_REF"
else
  echo "gitleaks detect \
    --source=$GITHUB_WORKSPACE \
    --config=$INPUT_CONFIG \
    --report-format=$INPUT_REPORT_FORMAT \
    --report-path=$INPUT_REPORT_PATH \
    --no-git=$INPUT_NO_GIT \
    --redact=$INPUT_REDACT \
    --exit-code=$INPUT_EXIT_CODE \
    --verbose=$INPUT_VERBOSE \
    --log-level=$INPUT_LOG_LEVEL"

  gitleaks detect \
    --source="$GITHUB_WORKSPACE" \
    --config="$INPUT_CONFIG" \
    --report-format="$INPUT_REPORT_FORMAT" \
    --report-path="$INPUT_REPORT_PATH" \
    --no-git="$INPUT_NO_GIT" \
    --redact="$INPUT_REDACT" \
    --exit-code="$INPUT_EXIT_CODE" \
    --verbose="$INPUT_VERBOSE" \
    --log-level="$INPUT_LOG_LEVEL"
fi

exit_code=$?

if [ $exit_code -eq 2 ]
then
  echo -e "\e[31mSTOP! Gitleaks encountered leaks"
  echo " ---------------------------------------------"
  echo "OUTPUT_EXIT_CODE=$exit_code" >> GITHUB_ENV
  exit 0
elif [ $exit_code -eq 1 ]
then
  echo -e "\e[31mSTOP! Gitleaks scan failed"
  echo " ---------------------------------------------"
  exit 1
else
  echo -e "\e[32mSUCCESS! Your code is good to go!"
  echo " ---------------------------------------------"
  echo "OUTPUT_EXIT_CODE=$exit_code" >> GITHUB_ENV
  exit 0
fi
