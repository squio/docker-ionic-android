FROM ubuntu:bionic

LABEL MAINTAINER="Weerayut Hongsa <kusumoto.com@gmail.com>"

ARG ANDROID_HOME="/opt/android-sdk"

ENV ANDROID_HOME "${ANDROID_HOME}"

RUN apt-get update
RUN apt-get install -y  \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       wget curl \
       unzip \
       git
       
       
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g @ionic/cli@^6.6 cordova@^9 @angular/cli@^9

# download and install Gradle
# https://services.gradle.org/distributions/
ARG GRADLE_VERSION=6.3
ARG GRADLE_DIST=bin
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-${GRADLE_DIST}.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip
ENV GRADLE_HOME /opt/gradle

WORKDIR /tmp

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
RUN unzip commandlinetools-*.zip
RUN rm ./commandlinetools*.zip
RUN mkdir $ANDROID_HOME
RUN mv tools $ANDROID_HOME
RUN mkdir "$ANDROID_HOME/licenses"

WORKDIR /

RUN $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --list
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;28.0.3" "platform-tools" "platforms;android-28"
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
RUN mkdir /ionicapp

WORKDIR /ionicapp



    
