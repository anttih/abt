The Alternative Build Tool for Scala projects
=============================================

**ABT is a skeleton DIY build tool to replace SBT and friends to give you back
control of your build.**

Build tools are among those problems where almost every project has unique
requirements. It's really hard to implement a tool to satisfy all those needs.
Content Management Systems historically suffer from the same syndrome, they all
tend to suck in their own unique ways. With build tools, the paths and tasks
are always slightly different and Convention Over Configuration rarely works
in practice. Many of the current build tools can do many things and are highly
configurable, but at a cost: the learning curve for setting up even a slightly
different build process can be high. These build tools accomplish what they do
by abstracting dependency retrieval, configuration and running tasks into their
own APIs and conventions; this is expected, but is often too much when all
you want to do is run a few carefully crafted shell commands.

So let's break this down, what are the pieces we need for building a scala
project? We need to be able to:

* Specify dependencies and retrieve them,
* compile scala files _incrementally_,
* build a class path from the dependencies and the compiled classes,
* run tasks which can depend on other tasks, and run only the tasks which are
  needed (you wouldn't want to fetch the dependencies every time you compile,
  for example), and
* an environment/language in which to write and run tasks.

**I believe you can build a small, fast and easily customizable build system
on your own by choosing tools designed to fill those specific needs**. The
tools I have chosen are:

* **[ivy][]**, for specifying dependencies, retrieving, and building a classpath
  of those dependencies,

* **[zinc][]**, for compiling scala files incrementally. Zinc has nailgun
  support built-in, so compilation is very fast.

* **[redo][]**, for building your project incrementally by allowing you to
  specify dependencies between your targets. redo is a make replacement, but
  much smaller (can be implemented in 250 lines of shell script), and uses
  plain shell commands for declaring dependencies.

* bash, or _any other_ (preferably) scripting language to write your tasks in.

[ivy]: http://ant.apache.org/ivy/
[zinc]: https://github.com/typesafehub/zinc
[redo]: https://github.com/apenwarr/redo

**This project is an example Scala project skeleton of those pieces packaged
together.** All of the tools are bundled. You only need to have scala, python
and bash installed.

You can run the example build by issuing `./abt run`.

    $ ./abt run
    redo  build/class_files
    redo    build/main.classpath
    Hello world! Time is 22:52.

What just happened? Before we can run the program we need to compile the scala
files (the `.build/class_files` target), and before that we need to retrieve the
dependencies and put them in the classpath (`.build/classpath.main.txt`). So
that's what's happening. Now if you run it again, you only see the output of
the program:

    $ ./abt run
    Hello world! Time is 22:53.

redo saw that there was nothing left to do except run the program. In
fact, if you now just compile—and didn't change any files—nothing happens:

    $ time ./abt compile
    ./abt compile  0.02s user 0.01s system 95% cpu 0.038 total

That 38 ms is redo invoking python and checking if any of the files have
changed.

You can get a list of available commands with `help`:
    
    $ ./abt help
    Usage: ./abt <task> [arguments]

    Available tasks:

        clean            Clean target directories
        compile          Compile all sources
        scala <args>     Execute scala command with the main classpath, passing in optional arguments
        help             Show usage (you're looking at it)
        package          Create a jar
        run              Run the program


## FAQ

### Is it any good?

You mean are ivy, zinc, redo and bash good? Yes, they are very good at what
they do.

### We've all seen build tools come and go. How is this any different?

Well, you see, this is not really a build tool in itself. This is an idea of
one. _You_ have to write your _own_ build script. This is just my idea of the
best tools for someone to write their own scala build system on top, and they
are packaged nicely together. Just fork and mod.

### Does it support Windows builds?

Probably not. You'd need a shell of some kind to run the tools.

### Can this be used in my project?

Sure it can, you just have to implement the tasks in whatever
language you want, and only that. This may or may not be a lot of work, but
you'll have full control of your build process.

### But I don't want to write my build file in bash. Can I use X?

Yes. There's no reason why you couldn't use any other language instead
of bash. All of the tools are just CLI programs. Even redo is just a bunch of
commands in `./bin/`.

