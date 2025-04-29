#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Use absolute paths in the tests to avoid directory confusion
setup() {
  SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  SCRIPT="${SCRIPT_DIR}/bids-converter.sh"
}

# Test 1: Check if the help message appears correctly
@test "Script shows help with --help" {
  run bash "$SCRIPT" --help
  assert_success
  assert_output --partial "Usage:"
}

# Test 2: Missing arguments shows usage
@test "Script shows usage when missing arguments" {
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  assert_output --partial "Usage:"
}

# Test 3: Error when unknown parameter is passed
@test "Script fails on unknown parameter" {
  run bash "$SCRIPT" /tmp "01" "001" --unknown-param
  [ "$status" -ne 0 ]
  assert_output --partial "Unknown parameter"
}
