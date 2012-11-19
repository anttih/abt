#!/usr/bin/env bash
redo-ifchange ../ivy.xml
ivy -confs default -cachepath $3 -ivy ../ivy.xml 1>ivy.log || (cat ivy.log >&2 && exit 1)
