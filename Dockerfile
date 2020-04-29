FROM ubuntu:bionic

LABEL MAINTAINER="Weerayut Hongsa <kusumoto.com@gmail.com>"

ARG ANDROID_SDK_VERSION="3859397"
ARG ANDROID_HOME="/opt/android-sdk"

ENV ANDROID_HOME "${ANDROID_HOME}"

RUN apt-get update
RUN apt-get install -y  \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       curl \
       unzip \
       git \
       gradle
       
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g @ionic/cli@^6.6 cordova@^9 @angular/cli@^9

WORKDIR /tmp

RUN curl -fSLk https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip -o commandlinetools.zip
RUN unzip commandlinetools.zip
RUN rm ./commandlinetools.zip
RUN mkdir $ANDROID_HOME
RUN mv tools $ANDROID_HOME

WORKDIR /

RUN $ANDROID_HOME/tools/bin/sdkmanager --list
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.3" "platform-tools" "platforms;android-28"
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --update
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
RUN mkdir /ionicapp

WORKDIR /ionicapp



    
