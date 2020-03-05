FROM alpine:latest AS jvm
# Set up shared environment variables
ARG jvm_version
ENV ENV_JVM_VERSION=$jvm_version
ENV JAVA_HOME="/usr/lib/jvm/java-1.${ENV_JVM_VERSION}-openjdk"
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

FROM jvm AS graal-initial
# Set up shared environment variables
ENV GRAAL_VERSION=20.0.0
ENV GRAAL_CE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz
# Add a marker file for debugging purposes
RUN touch stage_005.graal-initial
# Install java using the Alpine package manager
RUN apk add --no-cache wget tar gzip
RUN wget -q $GRAAL_CE_URL -O graalvm-ce-linux-amd64.tar.gz
RUN tar -xvzf graalvm-ce-linux-amd64.tar.gz
RUN ls graalvm-ce-java11-20.0.0
RUN mkdir -p /usr/lib/jvm
RUN mv graalvm-ce-java11-${GRAAL_VERSION} /usr/lib/jvm/graalvm
RUN rm -rf /usr/lib/jvm/graalvm/*src.zip \
  /usr/lib/jvm/graalvm/lib/missioncontrol \
  /usr/lib/jvm/graalvm/lib/visualvm \
  /usr/lib/jvm/graalvm/lib/*javafx* \
  /usr/lib/jvm/graalvm/jre/plugin \
  /usr/lib/jvm/graalvm/jre/bin/javaws \
  /usr/lib/jvm/graalvm/jre/bin/jjs \
  /usr/lib/jvm/graalvm/jre/bin/orbd \
  /usr/lib/jvm/graalvm/jre/bin/pack200 \
  /usr/lib/jvm/graalvm/jre/bin/policytool \
  /usr/lib/jvm/graalvm/jre/bin/rmid \
  /usr/lib/jvm/graalvm/jre/bin/rmiregistry \
  /usr/lib/jvm/graalvm/jre/bin/servertool \
  /usr/lib/jvm/graalvm/jre/bin/tnameserv \
  /usr/lib/jvm/graalvm/jre/bin/unpack200 \
  /usr/lib/jvm/graalvm/jre/lib/javaws.jar \
  /usr/lib/jvm/graalvm/jre/lib/deploy* \
  /usr/lib/jvm/graalvm/jre/lib/desktop \
  /usr/lib/jvm/graalvm/jre/lib/*javafx* \
  /usr/lib/jvm/graalvm/jre/lib/*jfx* \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libdecora_sse.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libprism_*.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libfxplugins.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libglass.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libgstreamer-lite.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libjavafx*.so \
  /usr/lib/jvm/graalvm/jre/lib/amd64/libjfx*.so \
  /usr/lib/jvm/graalvm/jre/lib/ext/jfxrt.jar \
  /usr/lib/jvm/graalvm/jre/lib/ext/nashorn.jar \
  /usr/lib/jvm/graalvm/jre/lib/oblique-fonts \
  /usr/lib/jvm/graalvm/jre/lib/plugin.jar \
  /usr/lib/jvm/graalvm/jre/languages/ \
  /usr/lib/jvm/graalvm/jre/lib/polyglot/ \
  /usr/lib/jvm/graalvm/jre/lib/installer/ \
  /usr/lib/jvm/graalvm/jre/lib/svm/ \
  /usr/lib/jvm/graalvm/jre/lib/truffle/ \
  /usr/lib/jvm/graalvm/jre/lib/jvmci \
  /usr/lib/jvm/graalvm/jre/lib/installer \
  /usr/lib/jvm/graalvm/jre/tools/ \
  /usr/lib/jvm/graalvm/jre/bin/js \
  /usr/lib/jvm/graalvm/jre/bin/gu \
  /usr/lib/jvm/graalvm/jre/bin/lli \
  /usr/lib/jvm/graalvm/jre/bin/native-image \
  /usr/lib/jvm/graalvm/jre/bin/node \
  /usr/lib/jvm/graalvm/jre/bin/npm \
  /usr/lib/jvm/graalvm/jre/bin/polyglot \
  /usr/lib/jvm/graalvm/sample/

RUN du -m /usr/lib/jvm/graalvm | sort -n

FROM graal-initial AS graaljdk11
# Set up shared environment variables
ENV JAVA_HOME=/usr/lib/jvm/graalvm
ENV GRAALVM_HOME=/usr/lib/jvm/graalvm
ENV PATH=$PATH:/usr/lib/jvm/graalvm/bin
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
# Add a marker file for debugging purposes
RUN touch stage_010.graaljdk11
# Add clib dependencies to allow GraalVM to run in Alpine
RUN apk add --no-cache --virtual .build-deps curl binutils \
  && GLIBC_VER="2.29-r0" \
  && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
  && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-9.1.0-2-x86_64.pkg.tar.xz" \
  && GCC_LIBS_SHA256="91dba90f3c20d32fcf7f1dbe91523653018aa0b8d2230b00f822f6722804cf08" \
  && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
  && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
  && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
  && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
  && echo "${SGERRAND_RSA_SHA256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
  && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/glibc-${GLIBC_VER}.apk \
  && apk add --no-cache /tmp/glibc-${GLIBC_VER}.apk \
  && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk > /tmp/glibc-bin-${GLIBC_VER}.apk \
  && apk add --no-cache /tmp/glibc-bin-${GLIBC_VER}.apk \
  && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk > /tmp/glibc-i18n-${GLIBC_VER}.apk \
  && apk add --no-cache /tmp/glibc-i18n-${GLIBC_VER}.apk \
  && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
  && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
  && curl -LfsS ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.xz \
  && echo "${GCC_LIBS_SHA256} */tmp/gcc-libs.tar.xz" | sha256sum -c - \
  && mkdir /tmp/gcc \
  && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
  && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
  && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
  && curl -LfsS ${ZLIB_URL} -o /tmp/libz.tar.xz \
  && echo "${ZLIB_SHA256} */tmp/libz.tar.xz" | sha256sum -c - \
  && mkdir /tmp/libz \
  && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
  && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
  && apk del --purge .build-deps glibc-i18n \
  && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar.xz /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

# Copy GraalVM from previous stage
COPY --from=graal-initial /usr/lib/jvm/graalvm /usr/lib/jvm/graalvm
RUN apk add --no-cache alpine-baselayout ca-certificates bash curl procps

# Install the GraalVM Native Imgage toolm using GU
RUN /usr/lib/jvm/graalvm/bin/gu available && /usr/lib/jvm/graalvm/bin/gu install native-image
