FROM ubuntu:20.04

LABEL MAINTAINER="squio <info@squio.nl>"

ARG ANDROID_SDK_ROOT="/opt/android-sdk"
ARG APPUSER="ionicbuild"

# versions
# gradle version must match version in cordova
#  `platforms/android/gradle/wrapper/gradle-wrapper.properties`: 
ARG GRADLE_VERSION="6.5"
ARG IONIC_VERSION="6.12.3"
ARG NODE_VERSION="15.x"
ARG CORDOVA_VERSION="10.0.0"
ARG ANDROID_SDK_VERSION="6858069_latest"
ARG ANDROID_BUILD_TOOLS_VERSION="29.0.2"
ARG ANDROID_PLATFORM="android-28"

# 1) Install system package dependencies
# 2) Install Nodejs/NPM/Ionic-Cli
# 3) Install Android SDK
# 4) Install SDK tool for support ionic build command
# 5) Cleanup
# 6) Add and set user for use by ionic and set work folder

ENV ANDROID_SDK_ROOT "${ANDROID_SDK_ROOT}"

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y  \
       build-essential \
       openjdk-8-jre \
       openjdk-8-jdk \
       wget curl \
       unzip \
       zipalign \
       zip \
       git

# https://github.com/nodesource/distributions
RUN curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}" | bash - \
    && apt-get install -y nodejs \
    && npm install -g "@ionic/cli@${IONIC_VERSION}" "cordova@${CORDOVA_VERSION}" \
    && npm install -g native-run

# download and install Gradle
# https://services.gradle.org/distributions/
# when entering this step /opt is supposed to be still empty
RUN cd /opt && \
    wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip" && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip
ENV GRADLE_HOME /opt/gradle/bin
ENV GRADLE_USER_HOME /opt/gradle
ENV PATH "$PATH:$GRADLE_HOME"


WORKDIR /tmp

RUN wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}.zip" \
    && unzip commandlinetools-*.zip \
    && rm ./commandlinetools*.zip \
    && mkdir -p "$ANDROID_SDK_ROOT/licenses" \
    && mv "cmdline-tools" "${ANDROID_SDK_ROOT}/"

WORKDIR /

# RUN $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --list
# omit platform-tools as it will be installed twice!?
# "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platform-tools" "platforms;${ANDROID_PLATFORM}" \
RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;${ANDROID_PLATFORM}" \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update \
    && yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
    
RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
    
# run image as a non privileged user
ENV USER="${APPUSER}"
ENV UID=1000
ENV GID=1000

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/$USER" \
    --ingroup "$USER" \
    --uid "$UID" \
    "$USER" \
    && usermod -a -G plugdev "$USER" \
    && chown -R "$USER":"$GID" /opt/android-sdk \
    && chown -R "$USER":"$GID" /opt/gradle

WORKDIR "/home/$USER"
USER $USER
