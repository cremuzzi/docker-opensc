# How to use this image

## 1. Run a simple container

First you need to plug in your USB crypto token or smartcard reader.

Then run a simple container:

```sh
docker run --name opensc --device /dev/bus/usb -d cremuzzi/opensc
```

Please notice the `--device` option. In this example we are are sharing our usb device with the container.

This image runs the `pcscd` daemon by default.

## 2. Execute any of the tools provided by OpenSC

for instance, you can dump a list of all the objects on your crypto device:

```sh
docker exec opensc pkcs15-tool -D
```

Please check the [OpenSC wiki](http://htmlpreview.github.io/?https://github.com/OpenSC/OpenSC/blob/master/doc/tools/tools.html) for further information on the tools provided by OpenSC.
