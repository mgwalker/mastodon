# toot.darkcooger.net

I run a small self-hosted Mastodon instance. I wanted my toot character limit to
be higher than what's available by default, so I created my own Dockerfile that
starts with the official image and patches it accordingly.

As I went through the pain of upgrading from Mastodon 4.2 to 4.3, I learned a
lot more about the various pieces and how they work together. (The pain wasn't
because of Mastodon – I also upgraded my Postgres and Redis databases by
several major versions, and it turned out I fat-fingered some configuration
that took me way too long to find.) At the end of it, I realized I could
document a lot of this for myself by creating a `docker-compose` file to
more-or-less capture my deployment. (I don't use `docker compose` in my
production environment, but something kinda similar.)

## Running this repo

The very first thing you'll need to do is fill out the `.env` and
`.mastodon.env` files. Postgres and Mastodon will both fail without those steps.
The `.env` file is where you'll put whatever youw ant your Postgres and Redis
credentials to be. Those are easy. (Literally just whatever you want.)

The `.mastodon.env` file has a few encryption secrets that need to be set.
Helpfully, Mastodon itself has some command-line tools for generating
appropriate secrets you can use. Instructions for generating good secrets are
in the `.mastodon.env` file itself.

Once you've got all those environment variables set, the next thing you'll need
to do is initialize the database. You can do that with:

```
docker compose run --rm init
```

> [!WARNING]
> Be sure to run this database initialization step before bringing the entire
> compose file up. If you don't, only the database will be created but not any
> of its tables. Mastodon will then refuse to startup and you'll need to fully
> delete the database and start over using `docker compose down -v`.

There should be a single log message and then the processes should stop. The
message should say:
```
Created database 'mastodon'
```

Now you're ready to go! Run

```
docker compose up
```

And then navigate to [http://localhost:8080](http://localhost:8080). Voila!
Your own local Mastodon server!

You can't really do much with it yet, but it's up and running. To get the
initial admin account setup, check out the
[Mastodon documentation](https://docs.joinmastodon.org/admin/setup/).

## A couple of notes

### nginx

If you were deploying this to production, you might want to spend some more time
on the nginx configuration. Primarily, if you look at `nginx.conf`, you'll see
on lines 11 and 20 that the proxy protocol is hardcoded to `https`. This tells
the Mastodon upstream that the incoming request was HTTPS even though it is not.
"Why would you lie like that?" you may be asking. Well, if Mastodon receives a
request that is *not* HTTPS, it sends a 301 redirect. Since I don't want to
create valid certificate for a local environment (and you probably don't either)
I told nginx to lie about it. Mastodon happily believes it's working only over
HTTPS and I don't have to deal with certs locally.

### Volumes

This configuration creates persistent volumes for Postgres, Redis, and Mastodon
itself. Mastodon stores a lot of stuff to disk, particularly media attachments,
user avatars, and custom emoji. (Probably other stuff too, I dunno.) You don't
really want all that stuff going away every time Mastodon restarts. If you
were deploying to production, you might want to change up how these volumes are
defined so you're less likely to accidentally delete them when bringing the
compose file down.