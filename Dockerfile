FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git sqlite inotify-tools

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get

ENV MIX_ENV=dev

COPY . .

EXPOSE 4000

CMD ["mix", "phx.server"]
