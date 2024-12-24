FROM tootsuite/mastodon:v4.2.13 AS src

FROM alpine/git AS patch
COPY --from=src /opt/mastodon /opt/mastodon

ADD char-limit.patch /char-limit.patch

WORKDIR /opt/mastodon
RUN git apply /char-limit.patch

CMD git diff

FROM tootsuite/mastodon:v4.2.13 AS final
COPY --from=patch /opt/mastodon /opt/mastodon

CMD rm -f /mastodon/tmp/pids/server.pid; bundle exec rails assets:precompile; bundle exec rails db:setup; bundle exec rails s -b 0.0.0.0 -p 3000