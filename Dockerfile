FROM ubuntu:xenial

LABEL MAINTAINER="Weerayut Hongsa <kusumoto.com@gmail.com>"

ARG NODEJS_VERSION="10"
ARG IONIC_VERSION="4.2.1"
ARG ANDROID_SDK_VERSION="3859397"
ARG ANDROID_HOME="/opt/android-sdk"

# 1) Install system package dependencies
# 2) Install Nodejs/NPM/Ionic-Cli
# 3) Install Android SDK
# 4) Install SDK tool for support ionic build command
# 5) Cleanup
# 6) Add and set user for use by ionic and set work folder

ENV ANDROID_HOME "${ANDROID_HOME}"

RUN apt-get update \
    && apt-get install -y \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       curl \
       unzip \
       git \
       gradle \
    && curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g @ionic/cli@^6.6 cordova@^9 @angular/cli@^9 \
    && cd /tmp \
    && curl -fSLk https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -o sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir $ANDROID_HOME \
    && mv tools /opt/android-sdk \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" "platform-tools" "platforms;android-28" \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --update \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --licenses \   
    && apt-get autoremove -y \
    && npm set unsafe-perm true \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && rm -rf /tmp/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \ 
    && mkdir /ionicapp

WORKDIR /ionicapp



    
