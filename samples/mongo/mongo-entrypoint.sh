#!/bin/bash

echo "DB PATH FOUND : ${DB_PATH}"

/usr/bin/mongod --dbpath ${DB_PATH}