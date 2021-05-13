FROM elixir:latest
WORKDIR /app/
COPY . /app/
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.clean --all
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
