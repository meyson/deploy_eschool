# All configuration files should be placed here

# App server
export BE_SERVER_1="10.156.0.50"
export BE_SERVER_2="10.156.0.51"
export FE_SERVER_1="10.156.0.11"
export FE_SERVER_2="10.156.0.12"

export BE_JAVA_PORT="8080"

# Database server
export DB_SERVER_IP="10.156.0.15"
export DATABASE="eschool_db"
export DB_USER_NAME="eschool"
export DB_USER_PWD="eschool"

# Load balancers
export FE_LB_IP="10.156.0.20"
export BE_LB_IP="10.156.0.30"

# For building
export DIST_DIR="app"
export DIST_DIR_BE="$DIST_DIR/be"
export DIST_DIR_FE="$DIST_DIR/fe"

# GCP
export LB_BE_EXT_IP="34.89.229.73"
export GCP_PROJECT_ID="test1-286117"
export GCP_KEY="~/.gcloud/test1-7b663e3daccc.json"
export SSH_USER="vova"
export SSH_KEY="~/.ssh/id_rsa"

# CIRCLECI


