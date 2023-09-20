#!/bin/sh
source .env.local

mongodump --uri=$MONGODB_URI --db=memedb