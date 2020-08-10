sudo apt-get install maven
sudo apt-get install openjdk-8-jdk

# install node version manager
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# install node js
nvm install "8.11.1"

npm install -g yarn
npm install -g @angular/cli@7.0.3