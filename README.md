Ruby Ship
=========

A portable ruby environment.

The goal of Ruby Ship is to have a single folder which is portable on all platforms. 

This is very usefull when developing ruby applications when your target audience does not have ruby installed, and you do not want to bother with installing ruby for them.

with Ruby Ship you can copy the entire folder into your project and use the wrappers supplied to make any ruby script run.

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

The ruby versions should be easy to update. Currently there are no update-script, but Ruby Ship will soon have this. It will  be as easy as this:

```
/tools/compile_ruby.sh path/to/source/tar_or_zip
```

Again: This is not made yet, but will be soon. Do you have the knowhow? Why don't you make a pull request?! :D

## License:

MIT

## TODO:

- Binary for all platforms (compiling from source)
- Make compile-script for each platform so anyone can update ruby version if needed. (should be easy)
- Have the compile script also generate the wrapper to take into consideration changing ruby versions.
- Make wrappers for bundle, gem, etc. (could be hard)
