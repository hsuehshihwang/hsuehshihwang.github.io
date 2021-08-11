#!/bin/bash
bundle exec jekyll build -d docs
bundle exec jekyll serve --host ${1-192.168.1.75} --port ${2-80} -d docs
