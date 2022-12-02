FROM bitnami/minideb:bullseye

USER root

# add bash
RUN apt-get update && apt-get install curl -y

WORKDIR /test

COPY ./test.sh .
RUN chmod +x ./test.sh

SHELL [ "/bin/bash" ]

CMD [ "./test.sh" ]
