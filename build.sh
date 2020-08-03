#!/usr/bin/env bash

# Check required environment variables
: "${BE_SERVER_IP:?Need to set env variable BE_SERVER_IP non-empty}"
: "${BE_JAVA_PORT:?Need to set env variable BE_JAVA_PORT non-empty}"
: "${FE_SERVER_IP:?Need to set env variable FE_SERVER_IP non-empty}"
: "${DB_SERVER_IP:?Need to set env variable DB_SERVER_IP non-empty}"
: "${DATABASE:?Need to set env variable DATABASE non-empty}"
: "${DB_USER_NAME:?Need to set env variable DB_USER_NAME non-empty}"
: "${DB_USER_PWD:?Need to set env variable DB_USER_PWD non-empty}"
: "${DIST_DIR:?Need to set env variable DIST_DIR non-empty}"
: "${DIST_DIR_BE:?Need to set env variable DIST_DIR_BE non-empty}"
: "${DIST_DIR_FE:?Need to set env variable DIST_DIR_FE non-empty}"

# clone repository if it doesn't exist otherwise just clear existing one
clone_repository() {
  local localrepo_vc_dir=$2/.git
  [ -d "$localrepo_vc_dir" ] || git clone "$1" "$2"
  (cd "$2"; git reset --hard; git pull "$1")
}

install_node() {
  if ! command -v nvm &> /dev/null
  then
      echo "Please install Node Version Manager."
      echo "To install or update nvm, you should run the install script."
      echo "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      exit 2
  fi
  # https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
  source ~/.nvm/nvm.sh
  nvm install "$1"
}

edit_be_files() {
  # todo change log lvl
  sed -i -e "s|localhost:3306/eschool|$DB_SERVER_IP:3306/$DATABASE|g" \
  eSchool/src/main/resources/application.properties
	sed -i -e "s|DATASOURCE_USERNAME:root|DATASOURCE_USERNAME:$DB_USER_NAME|g" \
	eSchool/src/main/resources/application.properties
	sed -i -e "s|DATASOURCE_PASSWORD:root|DATASOURCE_PASSWORD:$DB_USER_PWD|g" \
	eSchool/src/main/resources/application.properties
	sed -i -e "s|ESCHOOL_APP_HOST:https://fierce-shore-32592.herokuapp.com|ESCHOOL_APP_HOST:http://$BE_SERVER_IP:$BE_JAVA_PORT|g" \
	eSchool/src/main/resources/application.properties

  sed -i -e "s|35.242.199.77:3306/ejournal|$DB_SERVER_IP:3306/$DATABASE|g" \
  eSchool/src/main/resources/application-production.properties
	sed -i -e "s|DATASOURCE_USERNAME:root|DATASOURCE_USERNAME:$DB_USER_NAME|g" \
	eSchool/src/main/resources/application-production.properties
	sed -i -e "s|DATASOURCE_PASSWORD:CS5eWQxnja0lAESd|DATASOURCE_PASSWORD:$DB_USER_PWD|g" \
	eSchool/src/main/resources/application-production.properties
	sed -i -e "s|ESCHOOL_APP_HOST:https://35.240.41.176:8443|ESCHOOL_APP_HOST:http://$BE_SERVER_IP:$BE_JAVA_PORT|g" \
	eSchool/src/main/resources/application-production.properties
}

edit_fe_files() {
  # replace remote address with local IP
  sed -i -e "s|https://fierce-shore-32592.herokuapp.com|http://$BE_SERVER_IP|g" \
  final_project/src/app/services/token-interceptor.service.ts
}

build_backend() {
  cd eSchool
  mvn clean && mvn package -DskipTests
  cp target/eschool.jar "../$DIST_DIR_BE"
  echo "Backend is ready!"
  cd -
}

build_frontend() {
  cd final_project
  install_node "8.11.1"
  npm install yarn -g
  yarn install
  ng build --prod

  cp -a ./dist/eSchool/. "../$DIST_DIR_FE"
  echo "Frontend is ready!"
  cd -
}

main() {
  mkdir -p build
  cd build

  rm -rf "$DIST_DIR_FE"
  rm -rf "$DIST_DIR_BE"
  mkdir -p "$DIST_DIR_BE" "$DIST_DIR_FE"

  if ! command -v mvn &> /dev/null
  then
      echo "Please install Apache Maven >= 3.6.1 version"
      echo "sudo apt-get install maven"
      exit 1
  fi

  clone_repository https://github.com/protos-kr/eSchool.git eSchool
  edit_be_files
  build_backend

  clone_repository https://github.com/yurkovskiy/final_project.git final_project
  edit_fe_files
  build_frontend

  # files from new_files directory will be copied into corresponding
  # build/ folder
  cp -a "../new_files/$DIST_DIR_BE/." "$DIST_DIR_BE"
  cp -a "../new_files/$DIST_DIR_FE/." "$DIST_DIR_FE"
}

main "$@"