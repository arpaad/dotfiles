#!/usr/bin/env bash
# Phase 1 · system-wide tools we already use and want on every machine.
# YOU run this (sudo). Podman = containers; the PPA gives a newer git
# than Ubuntu ships (2.43 -> 2.5x).
PACKAGES="git podman"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y $PACKAGES
