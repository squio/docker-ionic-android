FROM ubuntu:bionic

LABEL MAINTAINER="cagianx <gianluca.cagnin@gmail.com>"

ARG ANDROID_SDK_ROOT="/opt/android-sdk"

ENV ANDROID_SDK_ROOT "${ANDROID_SDK_ROOT}"

RUN apt-get update
RUN apt-get install -y  \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       wget curl \
       unzip \
       zipalign \
       zip \
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
ENV GRADLE_HOME /opt/gradle/bin
ENV PATH "$PATH:$GRADLE_HOME"


WORKDIR /tmp

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
RUN unzip commandlinetools-*.zip
RUN rm ./commandlinetools*.zip
RUN mkdir $ANDROID_SDK_ROOT
RUN mv tools $ANDROID_SDK_ROOT
RUN mkdir "$ANDROID_SDK_ROOT/licenses"

WORKDIR /

RUN $ANDROID_SDK_ROOT/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --list
RUN yes | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;28.0.3" "platform-tools" "platforms;android-28"
RUN yes | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update
RUN yes | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
WORKDIR /
