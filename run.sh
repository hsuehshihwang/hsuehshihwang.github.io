#!/bin/bash
bundle exec jekyll serve --host ${1-192.168.1.75} --port ${2-80} -d docs
