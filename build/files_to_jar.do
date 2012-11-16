#!/bin/bash
redo-ifchange ../$BUILD_DIR/manifest.mf class_files

(cd ../$BUILD_DIR && find main -name "*.class")
jars=$(cat main.classpath | sed 's/:/\n/')
for jar in $jars; do cp $jar $BUILD_DIR; basename $jar; done
