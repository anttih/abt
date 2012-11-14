#!/bin/bash

BUILD_DIR=$PWD/.build
RESOURCES_DIR=$PWD/src/main/resources
TARGET_DIR=target
LIB_PATH=$(echo lib/*.jar | sed 's/ /:/g')
PATH=./bin:$PATH

scala_files () {
    find $@ -type f -name "*.scala"
}

compile () {
    scala_files src/main | \
      xargs zinc -log-level warn -nailed -classpath $(classpath_main) -d $TARGET_DIR/main >&2
}

classpath_main () {
  echo $LIB_PATH:`cat .build/classpath.main.txt`:$TARGET_DIR/main:$RESOURCES_DIR
}

# make sure we have a build dir
[ ! -d "$BUILD_DIR" ] && mkdir -p $BUILD_DIR

# redo will hang on a pipe to the zinc command when the nailgun server first
# starts. It just happens to be the file descriptor 51, we close it here.
# This problem should be solved elsewhere, but where?
# See discussion:
# <https://groups.google.com/forum/?fromgroups=#!topic/redo-list/usKuE2yOsxo>
exec 51>&-

case "$1" in
  run) redo-ifchange .build/class_files && scala -classpath $(classpath_main) HelloWorld ;;
  scala) redo-ifchange .build/class_files && (shift; scala -classpath $(classpath_main) "$@") ;;
  package) redo-ifchange $TARGET_DIR/hello.jar ;;
  compile) redo-ifchange .build/class_files ;;
  clean)
    for file in $(redo-targets); do [ -f $file ] && rm -v $file; done
    [ -d $TARGET_DIR/main ] && rm -r $TARGET_DIR/main
    exit 0
    ;;
  .build/class_files)
    scala_files src/main | xargs redo-ifchange .build/classpath.main.txt
    compile && echo "done"
    ;;
  .build/classpath.main.txt)
    redo-ifchange ivy.xml
    ivy -confs default -cachepath $3 -ivy ivy.xml 1>$BUILD_DIR/ivy.log || \
      (cat $BUILD_DIR/ivy.log >&2 && exit 1)
    ;;
  "$TARGET_DIR/hello.jar")
    redo-ifchange .build/files_to_jar

    # Running jar in combination with -C and @-file list syntax doesn't work,
    # so changing dirs manually here.
    export ROOT_DIR=$PWD
    (cd $TARGET_DIR && jar cmf manifest.mf $ROOT_DIR/$3 @$BUILD_DIR/files_to_jar) >&2
    ;;
  .build/files_to_jar)
    redo-ifchange $TARGET_DIR/manifest.mf .build/class_files

    (cd $TARGET_DIR && find main -name "*.class")
    jars=$(cat $BUILD_DIR/classpath.main.txt | sed 's/:/\n/')
    for jar in $jars; do cp $jar $TARGET_DIR; basename $jar; done
    ;;
  help)
    cat >&2 <<USAGE

Usage: ./abt <task> [arguments]

Available tasks:

    clean            Clean target directories
    compile          Compile all sources
    scala <args>     Execute scala command with the main classpath, passing in optional arguments
    help             Show usage (you're looking at it)
    package          Create a jar
    run              Run the program
USAGE
  ;;
esac

