#!/usr/bin/env bash
# Lock screen when YubiKey is removed
export XDG_RUNTIME_DIR=/run/user/$(id -u)
loginctl lock-session
