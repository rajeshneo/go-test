# Build Stage
FROM golang:alpine AS build-stage

LABEL app="build-go-test"
LABEL REPO="https://github.com/rajeshneo/go-test"

ENV PROJPATH=/go/src/github.com/rajeshneo/go-test

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/rajeshneo/go-test
WORKDIR /go/src/github.com/rajeshneo/go-test

RUN make build-alpine

# Final Stage
FROM alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/rajeshneo/go-test"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/go-test/bin

WORKDIR /opt/go-test/bin

COPY --from=build-stage /go/src/github.com/rajeshneo/go-test/bin/go-test /opt/go-test/bin/
RUN chmod +x /opt/go-test/bin/go-test

# Create appuser
RUN adduser -D -g '' go-test
USER go-test

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/go-test/bin/go-test"]
