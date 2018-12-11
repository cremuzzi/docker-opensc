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

# OpenSSL pkcs11 engine

This image comes with the libp11 engine for openssl. This allows you to use openssl with your crypto device.

For instance, You can create a CSR with your crypto device by first running a container with an openssl config file:

```sh
docker run --rm -v YOUR-HOST-PATH:/myssl --device /dev/bus/usb  --name opensc -d cremuzzi/opensc
```

where `YOUR-HOST-PATH` is a path on your host file system that contains an openssl config file (ex. my.conf). The config file must contain at least the following lines at the top:

```
openssl_conf = openssl_init

[openssl_init]
engines = engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
dynamic_path = /usr/lib/engines/pkcs11.so
MODULE_PATH = /usr/lib/pkcs11/opensc-pkcs11.so
init = 0
```

Then you can call openssl to create for instance a CSR (Certificate Signing Request):

```sh
docker exec -i -t opensc openssl req -engine pkcs11 -keyform engine -key "pkcs11:object=MY-PRIVATE-KEY-ID;type=private;" -new -config /myssl/my.conf -out /myssl/request.csr
```

where MY-PRIVATE-KEY-ID is the id of the private key stored on the crypto device.

You can find more information on OpenSSL with pkcs11 visiting  [github.com/OpenSC/libp11](https://github.com/OpenSC/libp11).
