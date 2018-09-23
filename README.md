# How to use this image

## First run the pcscd daemon

```sh
docker run --name opensc --device /dev/bus/usb -d cremuzzi/opensc
```
 
## Then run any of the tools provided by OpenSC

for instance, you can run pkcs11-tool:

```sh
docker exec opensc pkcs11-tool -O
```
