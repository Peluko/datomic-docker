# Datomic Starter Dev

Datomic binaries can't be redistributed, so you can't get a public Docker image for Datomic. The solution is to build your own private image providing the Datomic binaries you've downloaded after registering on Datomic.

This image runs a Datomic transactor and a peer for development purposes. It also runs Datomic Console.

Peer runs on port 8998 and console on 8080.

## Building instructions

1. Download Datomic Pro ([free Starter license](https://www.datomic.com/get-datomic.html)) binaries on ```downloads``` folder.
2. Edit ```Dockerfile``` to match the version number with the one downloaded.
3. Build (can use ```build-image.sh```)

## Configuration

Before running it, on ```/config``` folder must exist two files:

- ```dev-transactor.properties```: the config file for transactor. As a base you should use the file ```config/samples/dev-transator-template.properties``` of the downloaded Datomic .zip file. This file must:
    - Of course include a valid ```license-key```.
    - Use dev protocol.
    - Listen on localhost on port 4334 (see start.sh).
    - You can use a mounted folder for ```data-dir```. By default it should point to ```/data```.
- ```dbs-list```: a file that contains a list of the names of the dbs to be used. One line for each name. Each db will be created on startup if it doesnt exists. It's used to configure the peer. For example, a ```dbs-list``` which contains:
```
testing
devel
project2
```
on start will create three dbs and expose them on the peer. On subsequent starts, as the dbs are created, it will only expose them on the peer.

## Running

```bash
$ docker run -d -v ./config:/config -v ./data:/data -p 8080:8080 -p 8998:8998 --name datomic-dev peluko/datomic-dev
```

For accesing the Datomic REPL you can do:
```bash
$ docker exec -it datomic-dev /datomic-bin/datomic-pro/bin/repl
```
Use ```ctrl-d``` to exit.

## Delete a database

For deleting a database you can start a REPL and do
```clojure
(require '[datomic.api :as d])
(d/delete-database "datomic:dev://localhost:4334/DATABASE")
```

Remember to delete the database line from ```/config/dbs-list```. If not it will be recreated on next startup.
