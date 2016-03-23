Ruby Ship
=========

[![Join the chat at https://gitter.im/stephan-nordnes-eriksen/ruby_ship](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/stephan-nordnes-eriksen/ruby_ship?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Portable Ruby environment on any platform, with any version of MRI Ruby! No need to install Ruby on a computer to use it any more! 

The goal of Ruby Ship is to have a single folder containing Ruby, which is portable on all platforms. You can put this folder wherever you like and still be able to use the Ruby version on it. Put it on a USB stick if you like for all your Ruby-on-the-go needs!

This is very usefull when developing Ruby applications when your target audience do not have Ruby installed, and you do not want to bother with installing Ruby for them.

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
```
path/to/bin/ruby_ship_gem.sh [your normal gem args]
```

Example

```
path/to/bin/ruby_ship_gem.sh list
```


## Current pre-bundled versions of Ruby:

- Windows: 2.1.2p95 - Working
- Darwin (aka. OSx): 2.3.0p0 - Working
- Linux (Ubuntu): 2.1.2p95 - Working
- More platforms coming. 

## Building other ruby version

Getting a new version of ruby is super-easy! Go to https://www.ruby-lang.org/en/downloads/ and download the **tar.gz** you desire. Then run the following command. 

```
#For *nix
/tools/ruby_ship_build.sh path/to/source/ruby-X.Y.Z.tar.gz
```


 **(Windows build script is currently broken)**
 Building for windows requires the use of [ruby one click installer](https://github.com/oneclick/rubyinstaller/). See [issue 3](https://github.com/stephan-nordnes-eriksen/ruby_ship/issues/3) for explanation and how to build other versions on windows.
```
::For windows
::CURRENTLY BROKEN *sad-face* /tools/ruby_ship_build.bat path/to/source/ruby-X.Y.Z.tar.gz
```

**OSx specific:**
On OSx you have to relink quite a few dylibs to make it truly portable. This can be done by the supplied `auto_relink_dylib.rb`. This script will copy all needed dylibs into ruby_ship and then relink them, recursively adding any deeper dependencies. It is the only way to make ruby truly portable on the OSx platform. It is important that this script is run from the root of the directory, or else there will be mismatches of the directories.

```
ruby tools/auto_relink_dylibs.rb
#This can possibly be run with bin/ruby_ship.sh in stead of ruby, but I would advice against it as it will modify itself.
```

Thats it!

Now you can use your ruby_ship.sh/.bat with your newly compiled ruby version! The best part is: You can copy this environment (the entire folder) wherever you want, and it will still work! Ship it with your product, place it on a USB, or do whatever you want with it! No need to install ruby ever again!

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
- Interactive build tool that prompts you with different ruby versions.
- Online builder that downloads the ruby source and runs compile on it for you
- Online repo of multiple binaries for download (so you can choose ruby version without building yourself, and not download all of them at once)
- More awesome stuff
