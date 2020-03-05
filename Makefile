.PHONY: start build push

build_all:
	make build_jdk
	make build_jre

build_jdk:
	make build_openjdk8
	make build_openjdk11
	make build_graaljdk11

build_jre:
	make build_openjdk8-jre
	make build_openjdk11-jre

build_8:
	make build_openjdk8
	make build_openjdk8-jre

build_11:
	make build_openjdk11
	make build_openjdk11-jre
	make build_graaljdk11

build_openjdk8:
	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk --tag edwardlukeiw/jvm:openjdk8 .
	docker push edwardlukeiw/jvm:openjdk8

build_openjdk8-jre:
	docker build --file Dockerfile --build-arg jvm_version=8 --target openjdk-jre --tag edwardlukeiw/jvm:openjdk8-jre .
	docker push edwardlukeiw/jvm:openjdk8-jre

build_openjdk11:
	docker build --file Dockerfile --build-arg jvm_version=11 --target openjdk --tag edwardlukeiw/jvm:openjdk11 .
	docker push edwardlukeiw/jvm:openjdk11

build_openjdk11-jre:
	docker build --file Dockerfile --build-arg jvm_version=11 --target openjdk-jre --tag edwardlukeiw/jvm:openjdk11-jre .
	docker push edwardlukeiw/jvm:openjdk11-jre

build_graaljdk11:
	docker build --file Dockerfile --build-arg jvm_version=11 --target graaljdk11 --tag edwardlukeiw/jvm:graaljdk11 .
	docker push edwardlukeiw/jvm:graaljdk11

run_all:
	make run_openjdk8
	make run_openjdk8-jre
	make run_openjdk11
	make run_openjdk11-jre
	make run_graaljdk11

run_openjdk8:
	docker run -it edwardlukeiw/jvm:openjdk8 java -version
	docker run -it edwardlukeiw/jvm:openjdk8 javac -version
	docker run -it edwardlukeiw/jvm:openjdk8 ls

run_openjdk8-jre:
	docker run -it edwardlukeiw/jvm:openjdk8-jre java -version
	docker run -it edwardlukeiw/jvm:openjdk8-jre javac -version
	docker run -it edwardlukeiw/jvm:openjdk8-jre ls

run_openjdk11:
	docker run -it edwardlukeiw/jvm:openjdk11 java -version
	docker run -it edwardlukeiw/jvm:openjdk11 javac -version
	docker run -it edwardlukeiw/jvm:openjdk11 ls

run_openjdk11-jre:
	docker run -it edwardlukeiw/jvm:openjdk11-jre java -version
	docker run -it edwardlukeiw/jvm:openjdk11-jre javac -version
	docker run -it edwardlukeiw/jvm:openjdk11-jre ls

run_graaljdk11:
	docker run -it edwardlukeiw/jvm:graaljdk11 java -version
	docker run -it edwardlukeiw/jvm:graaljdk11 javac -version
	docker run -it edwardlukeiw/jvm:graaljdk11 ls
