FROM alpine:terragrunt:0.12.26

RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh"]

COPY ["src", "/src/"]

ENTRYPOINT ["/src/main.sh"]
