#!/usr/bin/env bash
# Session B · retire nvm.  Node is managed by mise now.
# RUN THIS ONLY AFTER restarting Claude Code so it runs on mise's node —
# verify first:  which claude   # should show .../mise/installs/node/...
# (This session is currently still on nvm's node; removing it live would break it.)
rm -rf ~/.nvm
# After this, also remove the NVM_DIR block from ~/.bashrc (Claude will do this,
# or delete the 3 lines mentioning NVM_DIR yourself).
