FROM python:3.6-slim

ENV LC_ALL C.UTF-8
ENV PYTHONIOENCODING utf-8
ENV APP sia
ENV BASEDIR /srv/apps/$APP
ENV APPDIR $BASEDIR/app
ENV SIADIR $BASEDIR/sia
ENV DATADIR $BASEDIR/data
ENV PATH $SIADIR:$PATH

# Create initial dirs
RUN mkdir -p $APPDIR $SIADIR $DATADIR
WORKDIR $APPDIR

# Install system dependencies
ENV RUNTIME_PACKAGES socat wget ca-certificates unzip
RUN apt-get update && \
    apt-get --no-install-recommends -y install $RUNTIME_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY pyproject.toml pyproject.lock $APPDIR/
RUN python3 -m pip install --no-cache-dir --upgrade pip poetry && \
    poetry install && \
    poetry cache:clear pypi --all

# Install Sia
ENV SIA_VERSION 1.3.7
ENV SIA_RELEASE https://sia.tech/releases/Sia-v${SIA_VERSION}-linux-amd64.zip
RUN wget --progress=bar:force:noscroll --show-progress -q $SIA_RELEASE -O $SIADIR/sia.zip && \
    unzip -q $SIADIR/sia.zip -d $SIADIR && \
    mv $SIADIR/Sia-v${SIA_VERSION}-linux-amd64/* $SIADIR && \
    rm -r $SIADIR/Sia-v${SIA_VERSION}-linux-amd64 && \
    rm $SIADIR/sia.zip

COPY run $APPDIR/

EXPOSE 8000
ENTRYPOINT ["poetry", "run", "python", "run"]
