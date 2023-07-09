#!/bin/sh
if kubectl get node -l podSize=SMALL; then exit 0; else exit 1; fi