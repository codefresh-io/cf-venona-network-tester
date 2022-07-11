FROM curlimages/curl:7.77.0

USER root

# add bash
RUN apk add --no-cache bash

WORKDIR /test

COPY ./test.sh .
RUN chmod +x ./test.sh

SHELL [ "/bin/bash" ]

CMD [ "./test.sh" ]
