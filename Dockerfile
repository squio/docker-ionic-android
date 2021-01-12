FROM ubuntu:20.04

LABEL MAINTAINER="squio <info@squio.nl>"

ARG ANDROID_SDK_ROOT="/opt/android-sdk"
ARG GRADLE_VERSION="6.3"
ARG GRADLE_DIST="bin"
ARG IONIC_VERSION="6.12.3"
ARG CORDOVA_VERSION="10.0.0"
ARG ANDROID_SDK_VERSION="6858069_latest"
ARG ANDROID_BUILD_TOOLS_VERSION="28.0.3"
ARG ANDROID_PLATFORM="android-28"
ARG APPUSER="ionicbuild"

# 1) Install system package dependencies
# 2) Install Nodejs/NPM/Ionic-Cli
# 3) Install Android SDK
# 4) Install SDK tool for support ionic build command
# 5) Cleanup
# 6) Add and set user for use by ionic and set work folder

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

RUN npm install -g "@ionic/cli@${IONIC_VERSION}" "cordova@${CORDOVA_VERSION}"

# download and install Gradle
# https://services.gradle.org/distributions/
RUN cd /opt && \
    wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-${GRADLE_DIST}.zip" && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip
ENV GRADLE_HOME /opt/gradle/bin
ENV PATH "$PATH:$GRADLE_HOME"


WORKDIR /tmp

RUN wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}.zip"
RUN unzip commandlinetools-*.zip
RUN rm ./commandlinetools*.zip
RUN mkdir $ANDROID_SDK_ROOT
RUN mv cmdline-tools $ANDROID_SDK_ROOT
RUN mkdir "$ANDROID_SDK_ROOT/licenses"

WORKDIR /

RUN $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --list
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platform-tools" "platforms;${ANDROID_PLATFORM}"
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
# run image as a non privileged user
ENV USER="${APPUSER}"
ENV UID=1000
ENV GID=1000
ENV WORKDIR "/$USER"

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/$USER" \
    --ingroup "$USER" \
    --uid "$UID" \
    "$USER" \
    && usermod -a -G plugdev "$USER"

WORKDIR "/$USER"
USER $USER

