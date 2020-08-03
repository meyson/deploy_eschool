# All configuration files should be placed here

# App server
export BE_SERVER_1="192.168.60.50"
export BE_SERVER_2="192.168.60.51"
export FE_SERVER_1="192.168.60.11"
export FE_SERVER_2="192.168.60.12"

export FE_VHOST_NAME="eschool"
export BE_JAVA_PORT="8080"

# Database server
export DB_SERVER_IP="192.168.60.15"
export DATABASE="eschool_db"
export DB_USER_NAME="eschool"
export DB_USER_PWD="eschool"

# Load balancers
export FE_LB_IP="192.168.60.20"
export BE_LB_IP="192.168.60.30"

# For building
export DIST_DIR="app"
export DIST_DIR_BE="$DIST_DIR/be"
export DIST_DIR_FE="$DIST_DIR/fe"
