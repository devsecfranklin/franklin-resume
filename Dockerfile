# syntax=docker/dockerfile:1

FROM python:3.10-slim-buster

LABEL maintainer "Franklin Diaz <2730246+devsecfranklin@users.noreply.github.com>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/franklin-resume"

WORKDIR /workspace
ENV MY_DIR /workspace
COPY . ${MY_DIR}

ENV DEBIAN_FRONTEND noninteractive

RUN \
  pip install Cython; \
  pip install -r${MY_DIR}/requirements.txt

CMD ["/usr/local/bin/python3", "${MY_DIR}/src/my_resume.py"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:5000/ || exit 1

# Set up my dude 
RUN addgroup --gid 9001 engr && \
	adduser \
    	--disabled-password \
    	--gecos "" \
    	--home "/home/franklin" \
    	--ingroup "engr" \
    	#--no-create-home \
    	--uid "9001" \
    	--uid "9001" \
    	"franklin"; \
	chown -R franklin:engr /home/franklin
RUN echo "permit nopass :engr\n" >> /etc/doas.conf; \
	if [ -f "/home/franklin/.bash_history" ]; then chmod 666 home/franklin/.bash_history; fi
USER franklin
