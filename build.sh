#!/usr/bin/env bash

# If a command fails, set -e will make the whole script exit,
# instead of just resuming on the next line.
set -e
# Treat unset variables as an error, and immediately exit.
set -u

# clone repository if it doesn't exist otherwise just clear existing one
clone_repository() {
  local localrepo_vc_dir=$2/.git
  [ -d "$localrepo_vc_dir" ] || git clone "$1" "$2"
  (cd "$2"; git reset --hard; git pull "$1")
}

install_node() {
  # https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
  source ~/.nvm/nvm.sh
  if [ "$?" != "0" ];
  then
      echo "Please install Node Version Manager."
      echo "To install or update nvm, you should run the install script."
      echo "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      exit 2
  fi
  nvm install "$1"
}

edit_be_files() {
  local props_dev="eSchool/src/main/resources/application.properties"
  sed -i -e "s|localhost:3306/eschool|$DB_SERVER_IP:3306/$DATABASE|g" $props_dev
	sed -i -e "s|DATASOURCE_USERNAME:root|DATASOURCE_USERNAME:$DB_USER_NAME|g" $props_dev
	sed -i -e "s|DATASOURCE_PASSWORD:root|DATASOURCE_PASSWORD:$DB_USER_PWD|g" $props_dev
	sed -i -e "s|ESCHOOL_APP_HOST:https://fierce-shore-32592.herokuapp.com|ESCHOOL_APP_HOST:http://localhost:$BE_JAVA_PORT|g" \
	$props_dev
	sed -i -e "s|logging.level.root=INFO|logging.level.root=ERROR|g" $props_dev
	sed -i -e "s|softserve.eschool=DEBUG|softserve.eschool=ERROR|g" $props_dev

  local props_prod="eSchool/src/main/resources/application-production.properties"
  sed -i -e "s|35.242.199.77:3306/ejournal|$DB_SERVER_IP:3306/$DATABASE|g" $props_prod
	sed -i -e "s|DATASOURCE_USERNAME:root|DATASOURCE_USERNAME:$DB_USER_NAME|g" $props_prod
	sed -i -e "s|DATASOURCE_PASSWORD:CS5eWQxnja0lAESd|DATASOURCE_PASSWORD:$DB_USER_PWD|g" $props_prod
	sed -i -e "s|ESCHOOL_APP_HOST:https://35.240.41.176:8443|ESCHOOL_APP_HOST:http://localhost:$BE_JAVA_PORT|g" \
	$props_prod
	sed -i -e "s|logging.level.root=INFO|logging.level.root=ERROR|g" $props_prod
	sed -i -e "s|softserve.eschool=INFO|softserve.eschool=ERROR|g" $props_prod
}

edit_fe_files() {
  # replace remote address with local IP
  sed -i -e "s|https://fierce-shore-32592.herokuapp.com|http://$BE_LB_IP|g" \
  final_project/src/app/services/token-interceptor.service.ts
}

build_backend() {
  local java_version
  # https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script
  java_version=$(java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*"/\1\2/p;')

  # check dependencies
  if ! command -v mvn &> /dev/null
  then
    echo "Please install Apache Maven >= 3.6.1 version"
    echo "sudo apt-get install maven"
    exit 2
  fi

  if [ "$java_version" != "18" ]
  then
    echo "You should install openjdk of 1.8.x version"
    echo "sudo apt-get install openjdk-8-jdk"
    exit 2
  fi

  cd eSchool
  mvn clean && mvn package -Dtest=\!ScheduleControllerIntegrationTest*
  cp target/eschool.jar "../$DIST_DIR"
  echo "Backend is ready!"
  cd -
}

build_frontend() {
  # check and install node
  install_node "8.11.1"

  if ! command -v yarn &> /dev/null
  then
    echo "Please install Angular yarn version globally"
    echo "npm install yarn -g"
    exit 2
  fi

  if ! command -v ng &> /dev/null
  then
    echo "Please install Angular 7.0.0 version globally"
    echo "npm install -g @angular/cli@7.0.3"
    exit 2
  fi

  cd final_project
  yarn install
  ng build --prod

  cp ../../config_files/fe/.htaccess ./dist/eSchool/.
  tar -czf "../$DIST_DIR/fe.tar.gz" -C ./dist/eSchool/ .
  echo "Frontend is ready!"
  cd -
}

main() {
  mkdir -p build
  cd build
  rm -rf "$DIST_DIR"
  mkdir -p "$DIST_DIR"

  clone_repository https://github.com/protos-kr/eSchool.git eSchool
  edit_be_files
  build_backend

  clone_repository https://github.com/yurkovskiy/final_project.git final_project
  edit_fe_files
  build_frontend
}

main "$@"
