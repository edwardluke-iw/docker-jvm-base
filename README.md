# docker-jvm-base
A docker multi-stage build to create base images for the JVM that can be used for both build images and runtime images in later multistage builds

## Building
This project is capable of generating a number of Docker images that contain different versions and flavours of the JVM. These can be executed with the Makefile or by runinng the docker commands manually.

### Docker Commands
The Makefile targets are simply wrappers for running the appropriate docker `build` command. For example the difference between the JDK8 and JDK11 builds are shown below:

The only difference between the two commands below is the `--build-arg jvm_version=` and the final image name.

Note the `--target` parameter which specifies which `stage` within the Dockerfile should be used to produce the final image. In the case below the `jvm_version` is used within the `openjdk` target to install the `openjdk8` or `openjdk11`

	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk --tag edwardlukeiw/jvm:openjdk8 .

	docker build --file Dockerfile --build-arg jvm_version=11 --target openjdk --tag edwardlukeiw/jvm:openjdk11 .

Therefore, the difference between building an `openjdk` vs an `openjdk-jre` image is based on changing the `target` parameter which specifies which stage in the Dockerfile produces the final image.

	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk --tag edwardlukeiw/jvm:openjdk8 .

	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk-jre --tag edwardlukeiw/jvm:openjdk11 .

	docker build --file Dockerfile --build-arg jvm_version=11 --target graaljdk11 --tag edwardlukeiw/jvm:graaljdk11 .

### Makefile

To build images for OpenJDK8, OpenJDK8-JVM, OpenJDK11, OpenJDK11-JVM, GraalVMJDK11:

    make build_all

To build just the OpenJDK images

    make build_jdk

To build just the OpenJDK-JRE images

    make build_jre

To build just the OpenJDK8 and OpenJDK8-JRE images:

    make build_8

To build just the OpenJDK8 and OpenJDK8-JRE images:

    make build_11

To build just the OpenJDK8 image:

    make build_openjdk8

To build just the OpenJDK8-JRE image:

    make build_openjdk8-jre

To build just the OpenJDK11 image:

    make build_openjdk11

To build just the OpenJDK11-JRE image:

    make build_openjdk11-jre

To build just the GraalJDK11 image:

    make build_graaljdk11-jre

## Dockerfile

The Dockerfile contains a number of named stages using the `AS` command which allows images to be built from layers created within previous build stages. There are three main stages defined within the file:

### `jvm`
This stage is based from the `alpine:latest` image. The stage is called `jvm` which is used as the base layer within the subsequent stages.

### `openjdk`
The `openjdk` stage extends the `jvm` base stage and installs a full JDK. This image can be used as the builder for projects which need to compile Java. This stage can produce final images when used with the following parameters in `docker build`:

    --target openjdk --build-arg jvm_version=X

### `openjdk-jre`
The `openjdk-jre` stage extends the `jvm` base stage and installs the minimal JRE. This image can be used as the runtime environment for projects which need to execute Java. This stage can produce final images when used with the following parameters in `docker build`:

    --target openjdk-jre --build-arg jvm_version=X

### GraalJDK11
Finally, the `graaljdk11` stage extends the `jvm` base stage and installs a GraalVM compliant JDK. This image can be used as the builder for projects which need to compile Java in to a single binary as it allows the `native-image` tool to be executed producing a static binary from the Java sources.

