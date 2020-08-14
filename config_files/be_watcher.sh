#!/usr/bin/env bash

app_dir="/opt/eschool"
app_path="$app_dir/eschool.jar"
artifact_url="eschool_url.txt"

APP_PSID=""

run_command() {
  java -jar "$app_path" -Dspring.profiles.active=production &
  APP_PSID=$!
  echo "Running! $(date) psid: $PSID"
}

restart_app() {
  local url=$(cat "$app_dir/$artifact_url")
  local app_path_tmp="$app_path.tmp"
  # download new artifact
  wget "$url" -O "$app_path_tmp"
  kill $APP_PSID || true
  # replace original artifact
  rm "$app_path"
  mv "$app_path_tmp" "$app_path"
  run_command
}

main() {
  # start program
  run_command

  # reload app when we deploy (change) file
  inotifywait -e close_write,moved_to,create -m "$app_dir" |
  while read -r directory events filename; do
    if [ "$filename" = "$artifact_url" ]; then
      restart_app
    fi
  done
}

# https://stackoverflow.com/questions/1715137/what-is-the-best-way-to-ensure-only-one-instance-of-a-bash-script-is-running/17480020
# run only one instance of this script
(
  flock -n 9 || exit 1
  main "$@"
) 9>/tmp/be_watcher.lock

