Ruby Ship
=========

Portable Ruby environment on any platform, with any version of MRI Ruby! No need to install Ruby on a computer to use it any more! 

The goal of Ruby Ship is to have a single folder which is portable on all platforms. 

This is very usefull when developing ruby applications when your target audience do not have Ruby installed, and you do not want to bother with installing Ruby for them.

With Ruby Ship you can copy the entire folder into your project and use the wrappers supplied to make any ruby script run.

Ruby Ship comes with tools to compile your favourite Ruby version too! This way, you are not stuck with the binaries that Ruby Ship happens to come with. 

![Ruby Ship](/image/ruby_ship.png?raw=true)


## Install:

- Step 1: Download this repository

- Step 2: Put the bin folder wherever you want it.

- Step 3: Use the ruby_ship wrappers as you would use the normal ruby command.

- Step 4: Party, Celebrate, and Contribute to Ruby Ship!


## Usage:

In a command line environment:
```
path/to/bin/ruby_ship.sh [your normal ruby args]
```
```
path/to/bin/ruby_ship.bat [your normal ruby args]
```

Example

```
path/to/bin/ruby_ship.bat -e "puts 'Ruby Ship works!'"
```

To use gem command:
WARNING: There is currently some path-problems with the gem command, as per Issue 1: https://github.com/stephan-nordnes-eriksen/ruby_ship/issues/1.
```
path/to/bin/ruby_ship_gem.sh [your normal gem args]
```

Example

```
path/to/bin/ruby_ship_gem.sh list
```

NOTE: Gem is only available on *nix systems (not windows) for now.

## Current pre-bundled versions of ruby:

- Windows: 2.1.2p95
- Darwin (aka. OSx): 2.1.2p95
- Linux-gnu (aka. Ubuntu): 2.1.2p95
- More platforms coming. 

## Building other ruby version

Getting a new version of ruby is super-easy! Go to https://www.ruby-lang.org/en/downloads/ and download the **tar.gz** you desire. Then run the following command. 

```
#For *nix
/tools/ruby_ship_build.sh path/to/source/ruby-X.Y.Z.tar.gz
```
```
::For windows
/tools/ruby_ship_build.bat path/to/source/ruby-X.Y.Z.tar.gz
```

Thats it! After this finishes you will have a new 'platform'\_ruby.sh ruby wrapper in your ruby\_ship/bin/ folder.

Now you can use your ruby_ship.sh/.bat with your newly compiled ruby version! The best part is: You can copy this environment wherever you want, and it will still work! Ship it with your product, place it on a USB, or do whatever you want with it! No need to install ruby ever again!

Note: You must compile ruby using ruby\_ship\_build on the platform you want to use this on, but only once :)

## Building requirements

To build on *nix you need to have the following:

- Build tools
- (Maybe others. TBA)

To build on windows you need to have the following:

- **7-zip with command line tools**. Remember to add to PATH variable (http://www.7-zip.org/)
- **nmake**. nmake comes bundled with any version of Visual Studio (http://www.visualstudio.com/) _NB: install to default location, or the script won't work_

## License:

MIT

## TODO:

- Binary for all platforms (compiling from source. Just run the ruby\_ship\_compiler on your platform)
- Make wrappers for bundle, gem, etc. (could be hard)
- Interactive build tool that prompts you with different ruby versions.
- Online builder that downloads the ruby source and runs compile on it for you
- Online repo of multiple binaries for download (so you can choose ruby version without building yourself, and not download all of them at once)
- More awesome stuff
