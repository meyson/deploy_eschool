#!/usr/bin/env bash
# TODO root > /home/user
WATCH_FILE="/root/eschool.jar"

PSID=""
run_command() {
  java -jar /root/eschool.jar -Dspring.profiles.active=production &
  PSID=$!
  echo "Running! $(date)"
}

reload_process() {
  kill $PSID || true
  run_command
}

# start program
run_command

# todo
WHEN=$(stat -c "%Y" $WATCH_FILE || true)
while true; do
  NOW=$(stat -c "%Y" $WATCH_FILE || true)
  if [ "$NOW" -gt "$WHEN" ]; then
    reload_process
  fi
  WHEN="$NOW"
  sleep 1
done;
