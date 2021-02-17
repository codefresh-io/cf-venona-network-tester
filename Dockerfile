FROM curlimages/curl:7.73.0

USER root

# add bash
RUN apk add --no-cache bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

WORKDIR /test

COPY ./test.sh .
RUN chmod +x ./test.sh

SHELL [ "/bin/bash" ]

CMD [ "./test.sh" ]