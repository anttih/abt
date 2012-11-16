#!/bin/bash
scala_files ../src/main | xargs redo-ifchange main.classpath
compile ../src/main && echo "done"
