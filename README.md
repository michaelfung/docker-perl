# docker-perl

Build docker images for development and production use.

## Build

We use a **multi-stage** Dockerfile to build both development and production image.

Build developemnt image:

    build-devel

Build runtime image for production:

    build-runtime

## Usage example

Look at the **app** folder.

## Build for other architecture locally

### Requirement

Prepare a multi-arch builder (e.g. crossbuilder):

    docker run --privileged --rm tonistiigi/binfmt --install all
    docker buildx create --name crossbuilder --use
    docker buildx inspect  crossbuilder --bootstrap

### Build for arm64

    docker buildx build --target devel --platform linux/arm64 -t michaelfung/perl-devel:5.36.3 . --push

    docker buildx build --target devel --platform linux/arm64 -t michaelfung/perl-rt:5.36.3 . --push

