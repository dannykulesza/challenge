FROM elixir:1.13.2

ADD . /
RUN chmod +x /bin/run.sh

# Install debian packages
RUN apt-get update && \
    apt-get install --yes build-essential inotify-tools postgresql-client git && \
    apt-get clean

# Install Phoenix packages
RUN mix local.hex --force

# Install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

RUN mix compile
RUN npm install --prefix ./assets

EXPOSE 4000