FROM python:3.9.23-bullseye
LABEL author="Alex Chen & Simon Sorensen (hello@simse.io)"

# Set timezone to Greenwich Mean Time
ENV TZ=GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add yarn to apt
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install common packages and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    gcc \
    libffi-dev \
    freetds-dev \
    nodejs \
    yarn

# Install Python packages
RUN pip install --upgrade pip setuptools wheel
RUN pip install cython pymssql

# Copy Chronos to image
COPY . /app/chronos

# Build Chronos UI
WORKDIR /app/chronos/chronos-ui
RUN yarn
RUN yarn build

# Set environment and expose ports and directories
EXPOSE 5000
VOLUME /chronos
ENV CHRONOS_PATH=/chronos
ENV CHRONOS=yes_sir_docker

# Install Python dependencies
WORKDIR /app/chronos
RUN pip install -r requirements.txt

ENTRYPOINT ["python", "chronos.py"]
