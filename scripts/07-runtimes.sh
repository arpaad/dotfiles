#!/usr/bin/env bash
# Phase 2 · runtimes via mise.  Run this in the NEW zsh shell.
GO_VERSION="1.27"
NODE_VERSION="24"
PYTHON_VERSION="3.14"
mise use -g go@$GO_VERSION
mise use -g node@$NODE_VERSION
mise use -g uv@latest
uv python install $PYTHON_VERSION
