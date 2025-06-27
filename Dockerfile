ARG MASTODON_VERSION
FROM ghcr.io/mastodon/mastodon:v${MASTODON_VERSION} AS src

FROM alpine/git AS patch
COPY --from=src /opt/mastodon /opt/mastodon

ADD char-limit.patch /char-limit.patch

WORKDIR /opt/mastodon
RUN git apply /char-limit.patch

FROM ghcr.io/mastodon/mastodon:v${MASTODON_VERSION} AS final
COPY --from=patch /opt/mastodon /opt/mastodon

CMD bundle exec rails s -b 0.0.0.0 -p 3000
