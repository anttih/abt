#!/bin/bash
redo-ifchange .build/files_to_jar
jar cmf manifest.mf $3 @../$BUILD_DIR/files_to_jar >&2
