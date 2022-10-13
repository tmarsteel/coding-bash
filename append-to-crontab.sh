#!/bin/bash

tmpCrontab="$(mktemp)"
trap "rm \"$tmpCrontab\"" EXIT
crontab -l > "$tmpCrontab"
cat /dev/stdin >>"$tmpCrontab"
crontab "$tmpCrontab"
