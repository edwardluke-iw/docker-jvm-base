FROM alpine:latest AS jvm
# Set up shared environment variables
ARG jvm_version
ENV ENV_JVM_VERSION=$jvm_version
ENV JAVA_HOME="/usr/lib/jvm/java-${ENV_JVM_VERSION}-openjdk"
ENV PATH="$JAVA_HOME/bin:${PATH}"
# Add a marker file for debugging purposes
RUN touch stage_000.jvm && touch stage_000.jvm${ENV_JVM_VERSION}

FROM jvm AS openjdk
# Add a marker file for debugging purposes
RUN touch stage_010.openjdk && touch stage_010.openjdk${ENV_JVM_VERSION}
# Install java using the Alpine package manager
RUN apk add openjdk${ENV_JVM_VERSION}
# Fixes JAVA_HOME as JDK8 lives in jvm/java-1.8-openjdk and JDK11 lives in jvm/java-11-openjdk
RUN ln -s /usr/lib/jvm/java-1.${ENV_JVM_VERSION}-openjdk/ /usr/lib/jvm/java-${ENV_JVM_VERSION}-openjdk

FROM jvm AS openjdk-jre
# Add a marker file for debugging purposes
RUN touch stage_010.openjdk-jre && touch stage_010.openjdk-jre${ENV_JVM_VERSION}
# Install java using the Alpine package manager
RUN apk add openjdk${ENV_JVM_VERSION}-jre
# Fixes JAVA_HOME as JDK8 lives in jvm/java-1.8-openjdk and JDK11 lives in jvm/java-11-openjdk
RUN ln -s /usr/lib/jvm/java-1.${ENV_JVM_VERSION}-openjdk/ /usr/lib/jvm/java-${ENV_JVM_VERSION}-openjdk

FROM oracle/graalvm-ce:latest as graaljdk11
RUN touch stage_010.graaljdk11
