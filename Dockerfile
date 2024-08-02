# Using multistage builds so the final image is smaller
# https://docs.docker.com/language/golang/build-images/#multi-stage-builds


###################
# 1. Building stage
###################
FROM golang:1.22.5 AS build-stage

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set destination for COPY
WORKDIR /1brc

# Install 7zip
RUN apt-get update && apt-get install -y p7zip-full

# Create directories
RUN \
  mkdir -p pre-data \
  mkdir -p data

# Copy the non compressed files
COPY data/*.out data/
COPY data/*.txt data/

# Copy the compressed .7z files
COPY data/*.7z.* pre-data/

# Extract .7z files
# Remove pre-data
RUN find pre-data -name "*.7z" -type f -print0 | xargs -0 -I{} 7z x -odata

# find pre-data -name "*.7z.*" -type f -print0 | xargs -0 -I{} 7z x {} -odata \
# Copy source code
COPY *.go ./
COPY go.mod ./

# Build bin and test bin
RUN \
  CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /1brc \
  && CGO_ENABLED=0 GOOS=linux go test -c -ldflags="-w -s" -a -installsuffix cgo -o /1brc



#######################
# 2. Build 10e9 dataset
#######################
FROM eclipse-temurin:17-jdk-jammy AS build-10e9-dataset
WORKDIR /1brc

# Copy source
COPY java/ gen/

# Compile and run java
RUN \
  javac gen/CreateMeasurements.java \
  && java gen/CreateMeasurements 1000000


###################
# 3. Benchmark
###################
FROM alpine:3.20.2 AS deploy-stage
WORKDIR /

COPY --from=build-10e9-dataset /1brc/measurements.txt measurements.txt
COPY --from=build-stage /1brc/data/ data/
COPY --from=build-stage /1brc/1brc* ./
COPY test.sh ./

CMD ["sh", "-c", "FORCE_CONTINUE=true", "./test.sh"]
