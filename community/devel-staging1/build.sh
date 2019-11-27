#!/bin/bash

cd community-repositories/devel/
export SAB_BUILDFILE=devel-build-staging1.yml
export CREATEREPO_PHASE=false
export ACCEPT_LICENSE=*

sark-localbuild
