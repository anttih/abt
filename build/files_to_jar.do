#!/bin/bash
redo-ifchange manifest.mf class_files

find main -name "*.class"
jars=$(cat main.classpath | sed 's/:/\n/')
for jar in $jars; do cp $jar .; basename $jar; done
