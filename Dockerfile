# ------------ Build go v8 library and run tests ----------------------------
FROM golang as builder
ARG GO_V8_DIR=/go/src/github.com/harikb/vEight/
ADD *.go *.h *.cc $GO_V8_DIR
ADD cmd $GO_V8_DIR/cmd/
ADD v8console $GO_V8_DIR/v8console/

# Copy the pre-compiled library & include files for the desired v8 version.
COPY libv8 $GO_V8_DIR/libv8/
COPY include $GO_V8_DIR/include/

# Install the go code and run tests.
WORKDIR $GO_V8_DIR
RUN go get ./...
RUN go test ./...

# ------------ Build the final container for v8-runjs -----------------------
# TODO(aroman) find a smaller container for the executable! For some reason,
# scratch, alpine, and busybox don't work. I wonder if it has something to do
# with cgo?
FROM ubuntu:16.04
COPY --from=builder /go/bin/v8-runjs /v8-runjs
CMD /v8-runjs
