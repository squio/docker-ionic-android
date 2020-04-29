FROM ubuntu:bionic

LABEL MAINTAINER="Weerayut Hongsa <kusumoto.com@gmail.com>"

ARG ANDROID_SDK_VERSION="3859397"
ARG ANDROID_HOME="/opt/android-sdk"

ENV ANDROID_HOME "${ANDROID_HOME}"
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN apt-get update
RUN apt-get install -y  \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       curl \
       unzip \
       git \
       gradle

RUN npm install -g @ionic/cli@^6.6 cordova@^9 @angular/cli@^9

RUN cd /tmp \
    && curl -fSLk https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -o sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir $ANDROID_HOME \
    && mv tools /opt/android-sdk \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" "platform-tools" "platforms;android-28" \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --update \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --licenses \
    && rm -rf /tmp/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
RUN mkdir /ionicapp

WORKDIR /ionicapp



    
