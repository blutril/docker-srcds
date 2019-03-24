This image is not tested!

# What is Source Dedicated Server?

Valve call this Server [Source SDK Base 2013 Dedicated Server](https://steamdb.info/app/244310/). This Server builds the base for all source engine based games with dedicated server support.

# Quick Start

## Basic

```
docker run \
    --expose 27015 \
    hackebein/srcds
```

## Enable API

```
docker run \
    --expose 27015 \
    -e "AUTHKEY=..." \
    hackebein/srcds
```
Get your [AUTHKEY](http://steamcommunity.com/dev/apikey)

## Public
If you have activated the API, this step happens automatically.

```
docker run \
    --expose 27015 \
    -e "GLST=..." \
    hackebein/srcds
```

Get your [GLST](http://steamcommunity.com/dev/managegameservers) (`APPID: 244310`)

## Additional Environment

PORT: Connection Port
(`Default: 27015`)

CLIENTPORT:
(`Default: 27005`)

TVPORT:
(`Default: 27020`)

SPORT:
(`Default: 26900`)

CUSTOMPARAMETERS: additional parameters
(`Default: `)