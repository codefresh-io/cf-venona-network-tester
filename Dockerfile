FROM bitnami/minideb:bullseye

USER root

# add bash
RUN apt-get update && apt-get install curl -y && rm -rf /var/lib/apt/lists/* 

WORKDIR /test

COPY ./test.sh .
RUN chmod +x ./test.sh

SHELL [ "/bin/bash" ]

CMD [ "./test.sh" ]
