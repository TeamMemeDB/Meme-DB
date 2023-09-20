#!/bin/sh
source .env.local

mongorestore --uri=$MONGODB_URI memedb