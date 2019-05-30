#!/bin/sh

set -e

pcscd

exec "$@"
