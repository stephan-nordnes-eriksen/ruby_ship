Ruby Ship
=========

A portable ruby environment.

The goal of Ruby Ship is to have a single folder which is portable on all platforms. 

This is very usefull when developing ruby applications when your target audience does not have ruby installed, and you do not want to bother with installing ruby for them.

With Ruby Ship you can copy the entire folder into your project and use the wrappers supplied to make any ruby script run.

![Ruby Ship](/image/ruby_ship.png?raw=true)

## Install:

- Step 1: Download this repository

- Step 2: Put the bin folder wherever you want it.

- Step 3: Use the wrappers as you would use the normal ruby command.

- Step 4: Party, Celebrate, and Contribute to Ruby Ship!


## Usage:

in a command line environment:
```
path/to/bin/osx_ruby.sh [your normal ruby args]
```
```
path/to/bin/win_ruby.bat [your normal ruby args]
```
example

path/to/bin/win_ruby.bat -e "puts 'Ruby Ship works!'"



## Current versions of ruby:

- Windows: 2.0.0p481
- OSx: 2.1.2p95
- More platforms coming. 

## Building other ruby version

Getting a new version of ruby is super-easy! Go to https://www.ruby-lang.org/en/downloads/ and download the **tar.gz** you desire. Then run the following command. 

```
/tools/nix_compile_ruby.sh path/to/source/ruby-X.Y.Z.tar.gz
```

Thats it! After this finishes you will have a new nix\_ruby.sh ruby wrapper in your ruby\_ship/bin/ folder.

Currently there is no build script for Windows. Feel free to make one if you would like :) Or just wait til I get around to it.

## License:

MIT

## TODO:

- Binary for all platforms (compiling from source)
- Make compile-script for each platform so anyone can update ruby version if needed. (should be easy)
- Have the compile script also generate the wrapper to take into consideration changing ruby versions.
- Make wrappers for bundle, gem, etc. (could be hard)
