#!/usr/bin/env bash
set -ex

python -m twisted.trial tests.handlers.test_sync.SyncTestCase