FROM golang:alpine
WORKDIR /go/src/app
RUN apk add --no-cache git \
    && go get github.com/robfig/cron \
    && apk del git
# install curl
RUN apk update \
    && apk add --no-cache openssl curl \
    && apk add bash
RUN mkdir dumpdata
RUN apk add python
RUN apk add py-pip
RUN pip install awscli
RUN apk add --update coreutils
COPY . .
RUN go build backup.go
RUN chmod +x cron_script.sh
RUN chmod +x cleaner.sh
CMD ["./backup"]