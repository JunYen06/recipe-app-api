# First, define the name of the image
FROM python:3.9-alpine3.13
# "3.9-alpine3.13" is the name of the tag, alpine is a lightweight version of Linux that is very stripped back, 
# very efficient and lightweight for docker.

LABEL maintainer="jlim356"
# just best practice to define this

ENV PYTHONUNBUFFERED 1
# recomended when running python in a docker container, tells python that you don't want to buffer the output,
# prevents delays from python to docker logs

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# COPY FROM TO (inside container)
WORKDIR /app
# working directory that all commands will be run from when we run commands on docker image
# set to location where django project is synced to
EXPOSE 8000
# expose port 8000 from container to machine

ARG DEV=false
# by default, we are not running in developer mode

# runs the RUN command on the python alpine image when building the image
# the && \ syntax makes the build of images more effecient because it doesn't create many layers
RUN python -m venv /py && \
    # create virtual env to store dependencies
    /py/bin/pip install --upgrade pip && \
    # specify full path of the virtual env and upgrades python package manager inside virtual env
    /py/bin/pip install -r /tmp/requirements.txt && \
    # installs list of requirements into docker image inside virtual env
    if [ $DEV = true ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # shell script that checks if DEV env is true
    rm -rf /tmp && \
    # removes the temporary directory because we don't want extra dependencies on our docker image
    adduser \
    # best practice because we don't want to use the root user for everything
        --disabled-password \
        --no-create-home \
        django-user
# this "django-user" is the name of the user

ENV PATH="/py/bin:$PATH"
# updates the PATH env variable inside the image
# PATH (auto generated in Linux) defines all the directories where executables can be run

USER django-user
# defines the user we are switching to, eveything before this line is done as a root user