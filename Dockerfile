FROM ubuntu:20.04

LABEL MAINTAINER="squio <info@squio.nl>"

ARG ANDROID_SDK_ROOT="/opt/android-sdk"

ENV ANDROID_SDK_ROOT "${ANDROID_SDK_ROOT}"

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
       
       
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

RUN npm install -g @ionic/cli@6.12.3 cordova@10.0.0

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

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
RUN unzip commandlinetools-*.zip
RUN rm ./commandlinetools*.zip
RUN mkdir $ANDROID_SDK_ROOT
RUN mv cmdline-tools $ANDROID_SDK_ROOT
RUN mkdir "$ANDROID_SDK_ROOT/licenses"

WORKDIR /

RUN $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --list
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;28.0.3" "platform-tools" "platforms;android-28"
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
WORKDIR /
