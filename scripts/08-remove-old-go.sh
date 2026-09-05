#!/usr/bin/env bash
# Phase 2 · remove the old manual Go.  YOU run this (sudo), only AFTER
# `go version` shows Go now comes from mise (~/.local/share/mise/...).
sudo rm -rf /usr/local/go
