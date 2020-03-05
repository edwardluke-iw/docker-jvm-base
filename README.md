# docker-jvm-base
A docker multi-stage build to create base images for the JVM that can be used for both build images and runtime images in later multistage builds

## Building
This project is capable of generating a number of Docker images that contain different versions and flavours of the JVM. These can be executed with the Makefile or by runinng the docker commands manually.

### Docker Commands
The Makefile targets above are simply running the equivalent docker `build` command. For example the difference between the JDK8 and JDK11 builds are shown below:

The only change is the `jvm_version` build arg and the final image name.

	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk --tag edwardlukeiw/jvm:openjdk8 .

	docker build --file Dockerfile --build-arg jvm_version=11 --target openjdk --tag edwardlukeiw/jvm:openjdk11 .

Similarly, the difference between building a `openjdk` vs an `openjdk-jre` image is based on changing the `target` parameter which modifies which stage in the Dockerfile produces the final image.

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

The Dockerfile contains a number of named stages using the `AS` command which allows imasges to be built from layers created within previous build stages. There are three main stages defined within the file:

### JVM Base
The base layer for this project is `alpine:latest` which is used to define a stage called `jvm`. This stage is used as a layer within the subsequent stages.

### OpenJDK and OpenJDK-JRE
The `jvm` base stage is extented by either the `openjdk` or `openjdk-jvm` stages. These stages use the `build-arg java_version=X` to install the specified version of the JDK or the JVM.

### GraalJDK11
Additionally the `jvm` base stage can be extended by the `graaljdk11` stage which installs a GraalVM compliant JDK and allows the `native-image` tool to be executed producing a static binary from the Java sources.

