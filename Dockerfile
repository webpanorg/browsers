FROM ubuntu:22.04
RUN apt-get update -y;
RUN apt-get upgrade -y;

RUN apt-get install -y gnupg
RUN apt-get install -y dbus
RUN apt-get install -y dumb-init
RUN apt-get install -y unzip
RUN apt-get install -y curl
RUN apt-get install -y ffmpeg
RUN apt-get install -y xvfb
RUN apt-get install -y x11vnc

# Install NVM
WORKDIR /usr/src

ENV NVM_DIR /usr/src/nvm
ENV NODE_VERSION v20.6.0
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/bin
ENV PATH $NODE_PATH:$PATH

RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"

# Install chromium with dependency
# https://playwright.dev/docs/browsers#install-browsers

RUN PLAYWRIGHT_BROWSERS_PATH=/usr/src npx playwright install --with-deps webkit
# Rename /usr/src/webkit-xxxxx to /usr/src/webkit
RUN cd /usr/src && mv $(ls -d webkit-*) webkit

RUN PLAYWRIGHT_BROWSERS_PATH=/usr/src npx playwright install --with-deps firefox
# Move /usr/src/firefox-xxxxx/firefox to /usr/src/firefox
# And clearfix /usr/src/firefox-xxxxx;
RUN mv /usr/src/$(ls -d firefox-*)/firefox /usr/src/firefox
RUN rm -rf /usr/src/$(ls -d firefox-*)

# Chromium 
RUN PLAYWRIGHT_BROWSERS_PATH=/usr/src npx playwright install --with-deps chromium
# Move /usr/src/chromium-xxxxx/chrome-linux to /usr/src/chromium
# And clearfix /usr/src/chromium-xxxxx;
RUN mv /usr/src/$(ls -d chromium-*)/chrome-linux /usr/src/chromium
RUN rm -rf /usr/src/$(ls -d chromium-*)

# Chromium has especialy method (screencast)
# And playwright automaticaly load ffmpeg to record screencast
# But container already has ffmpeg
# Delete /usr/src/ffmpeg-xxxxx
RUN cd /usr/src && rm -rf $(ls -d ffmpeg-*)
RUN rm -rf ~/.npm/_npx
