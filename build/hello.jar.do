#!/bin/bash
redo-ifchange files_to_jar
jar cmf manifest.mf $3 @files_to_jar >&2
