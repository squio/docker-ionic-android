# docker-ionic-android-sdk

![Docker Image CI](https://github.com/squio/docker-ionic-android/workflows/Docker%20Image%20CI/badge.svg?branch=master)

Docker image including Android SDK for building Ionic framework application.

The Docker image is published to Docker Hub as [squio/ionic-android](https://hub.docker.com/r/squio/ionic-android)

Many thanks to

- [@Kusumoto](https://github.com/Kusumoto) - original author
- [@cagianx](https://github.com/cagianx) - updated Docker file

## Usage

If you want to run or build an ionic project in computer but doesn't have Android Studio,
Android SDK or Ionic Framework you can use the following docker commands in your Ionic working directory:

- Restore npm package

```sh
docker run --rm -v $(pwd):/ionicapp squio/ionic-android npm install
```

- Preview Ionic web app in your web browser

```sh
docker run --rm -v $(pwd):/ionicapp -p 8100:8100 squio/ionic-android ionic serve
```

- Build android apk output file

```sh
docker run --rm -v $(pwd):/ionicapp squio/ionic-android ionic cordova build android
```

## ADB Support

You can use adb (Android debug bridge) in this docker image using this command.
(Special thanks [@aruelo](https://github.com/aruelo) for instrcution in issue
[#17](https://github.com/Kusumoto/docker-ionic-android-sdk/issues/17))

```sh
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -P -v $(pwd):/ionicapp squio/ionic-android /opt/android-sdk/platform-tools/adb devices
```
