#!/usr/bin/env bash

echo "You can detach from your tmux session by pressing Ctrl+B then D"
read -p "Press enter to continue " && tmux attach-session -t MineCraft
