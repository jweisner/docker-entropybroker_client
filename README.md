# docker-entropybroker_client
Docker container for feeding entropy_broker data to the Docker host

This is a privileged container that feeds the Docker host's kernel with entropy data from an [entropy-broker](https://www.vanheusden.com/entropybroker/). This is useful for improving the quality of the RNG for generation of PKI keys and certificates. If your Docker host already has good quality entropy, you don't need this. This is most useful for Docker engines running in virtual machines (OSX, Windows, and especially VMware).

## Prerequisites
* an entropy-broker with a good qualty entropy source available over the network
* a username and password on the entropy broker
* Docker

## Build
```
git clone https://github.com/jweisner/docker-entropybroker_client.git
cd docker-entropybroker_client
docker build -t entropybroker_client .
```

## Usage
```
docker run -d --privileged \
    --name entropyclient \
    -e BROKER_HOST=192.168.1.1 \
    -e CLIENT_USERNAME=joe_user \
    -e CLIENT_PASSWORD=my_password1234123492348 \
    entropybroker_client
```
This container will pull entropy data from the broker every 5 seconds (tunable with environment variable ENTROPY_STIR) and feed it to the kernel's entropy pool.

Make sure it's running and able to pull data from the broker:
```
$ docker logs entropyclient
eb_client_linux_kernel v2.9, (C) 2009-2015 by folkert@vanheusden.com
Fri Mar  8 21:25:11 2019]6| started with 3085 bits in kernel rng
Fri Mar  8 21:25:11 2019]7| wait for low-event
Fri Mar  8 21:25:16 2019]7| kernel rng bit count: 3085
Fri Mar  8 21:25:16 2019]6| 3085 bits left (4096 max), will get 1011 bits
Fri Mar  8 21:25:16 2019]6| Connecting to 192.168.1.1:55225
Fri Mar  8 21:25:16 2019]7| handshake hash: sha512, data mac: md5, data cipher: 3des
Fri Mar  8 21:25:16 2019]6| Connected
Fri Mar  8 21:25:16 2019]7| Send request (0001)
Fri Mar  8 21:25:16 2019]7| received reply: 0002
Fri Mar  8 21:25:16 2019]6| server is offering 1016 bits (127 bytes)
Fri Mar  8 21:25:16 2019]7| got 1016 bits
Fri Mar  8 21:25:16 2019]7| new entropy count: 3242
Fri Mar  8 21:25:16 2019]7| wait for low-event
...
```

In another container (ie. the container where you want to run your RNG):
```
$ docker run --rm -it busybox /bin/dd if=/dev/random of=/dev/null bs=1k count=5
0+5 records in
0+5 records out
358 bytes (358B) copied, 0.000247 seconds, 1.4MB/s
```

You can pull data from /dev/random while tailing the output from the `entropyclient` container and see that the client is pulling data from the broker when the entropy pool gets low enough.
