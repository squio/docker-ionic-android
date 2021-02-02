# docker-ionic-android-sdk

![Docker Image CI](https://github.com/squio/docker-ionic-android/workflows/Docker%20Image%20CI/badge.svg?branch=master)

Docker image including Android SDK for building Ionic framework application.

The Docker image is published to Docker Hub as [squio/ionic-android](https://hub.docker.com/r/squio/ionic-android)

Many thanks to

- [@Kusumoto](https://github.com/Kusumoto) - original author
- [@cagianx](https://github.com/cagianx) - updated Docker file

## Usage

If you want to run or build an ionic project on your computer but don't have Android Studio,
Android SDK or Ionic Framework you can use the following docker commands in your Ionic working directory:

- Update npm packages

```sh
docker run --rm -v $(pwd):/ionicapp -w /ionicapp squio/ionic-android npm install
```

- Preview Ionic web app in your web browser

```sh
docker run --rm -v $(pwd):/ionicapp -w /ionicapp -p 8100:8100 squio/ionic-android ionic serve
```

- Build android apk output file

```sh
docker run --rm -v $(pwd):/ionicapp -w /ionicapp squio/ionic-android ionic cordova build android
```

The build will be in `./platforms/android/app/build/outputs/apk/debug/app-debug.apk`

## ADB Support

You can use adb (Android debug bridge) in this docker image using this command.
(Special thanks [@aruelo](https://github.com/aruelo) for instrcution in issue
[#17](https://github.com/Kusumoto/docker-ionic-android-sdk/issues/17))

```sh
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -P -v $(pwd):/ionicapp squio/ionic-android /opt/android-sdk/platform-tools/adb devices
```

Now you might be able to run your app directly on your device with the command:

```sh
docker run --rm -v $(pwd):/ionicapp -w /ionicapp squio/ionic-android ionic cordova run android
```

If you get a permission denied error make sure your phone has:

- enabled developer tools
- enabled USB debugging in developer options
- select "USB for file transfer" after plugging in the USB cable
- check "Allow this computer" when prompted at the ADB connect

You mnight get an error indicating that the App already exists with a different
signing key; in that case you must manually uninstall the previous version of
your app from the phone before executing the `run` command again.

## Versions

Docker container build args:

```sh
GRADLE_VERSION="6.5"
IONIC_VERSION="6.12.3"
NODE_VERSION="15.x"
CORDOVA_VERSION="10.0.0"
ANDROID_SDK_VERSION="6858069_latest"
ANDROID_BUILD_TOOLS_VERSION="29.0.2"
ANDROID_PLATFORM="android-28"
```

Make sure to keep the gradle version consistent with the version which is
specified with the installed cordova version.

This can be found in
`platforms/android/gradle/wrapper/gradle-wrapper.properties`

## Keep gradle environment changes

The `gradlew` build ernvironment is recreated for your project whenever an
android build is made. This takes time, especially in a low bandwidth environment.

Also the keystore for debug signing is recreated, so you will need to uninstall
a previous debug app from your Android device before you can install a new build.

To keep the changes whcih the container made you can `commit` them to your image
as follows:

Run the build command without the `--rm` flag

`docker run -v $(pwd):/ionicapp -w /ionicapp squio/ionic-android ionic cordova build android`

Find the id of the build container with `docker container ls -a`

Then commit the changes with: `docker commit 32cafffb0f5f squio/ionic-android:latest`
