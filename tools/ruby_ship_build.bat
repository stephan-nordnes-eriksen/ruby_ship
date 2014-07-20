@echo off

if [%1]==[] (
	echo "No arguments supplied"
    echo "Usage: win_compile_ruby.sh /path/to/ruby_source.tar.gz"
   
    exit /B
   
)

call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

echo "Compiling and installing ruby"
:: PRE INSTALL CLEANUP
rm -rf %~dp0/../bin/win_ruby
rm -rf %~dp0/extracted_ruby
mkdir %~dp0/extracted_ruby
mkdir %~dp0/../bin/win_ruby

:: UNZIP SOURCE
7z x %~f1 -so | 7z x -aoa -si -ttar -o"%~dp0/extracted_ruby"

:: GET RUBY VERSION AND DIRECTORY
for /f %%i in ('ls %~dp0/extracted_ruby') do set RUBYDIR=%%i
for /f %%i in ('echo %RUBYDIR% ^| cut -d'-' -f 2') do set RUBY_VERSION=%%i

echo "############################"
echo "Ruby Ship is Installing ruby version %RUBY_VERSION%"
echo "############################"

:: BUILDING RUBY
cd "%~dp0/extracted_ruby/%RUBYDIR%"
call %~dp0/extracted_ruby/%RUBYDIR%/win32/configure.bat --enable-load-relative --prefix=%~dp0/../bin/shipyard/win_ruby
nmake
nmake test
nmake install

:: SETTING UP REFERENCE DIRECTORIES
for /f %%i in ('ls %~dp0/../bin/shipyard/win_ruby/include') do set RUBY_INSTALL_DIR=%%i
for /f %%i in ('echo %RUBY_INSTALL_DIR% ^| cut -d'-' -f 2') do set RUBY_VERSION_DIR=%%i
for /f %%i in ('ls %~dp0/../bin/shipyard/win_ruby/lib/ruby/%RUBY_VERSION_DIR% | FindStr /mswin/') do set RUBY_BINARY_VERSION_DIR=%%i
:: SETTING UP COMMON WRAPPER COMPONENTS

:: MAKING THE SCRIPT:

echo %RUBY_INSTALL_DIR%


echo @echo off > %~dp0/../bin/win_ruby.bat
echo %%~dp0\win_ruby\bin\ruby.exe %%* >> %~dp0/../bin/win_ruby.bat

echo @echo off > %~dp0/../bin/win_gem.bat
echo %%~dp0\win_ruby\bin\gem.bat %%* >> %~dp0/../bin/win_gem.bat

:: Clean up:
cd %~dp0
rm -rf %~dp0/extracted_ruby

echo "Ruby Ship finished installing Ruby %RUBY_VERSION%!"
echo "Run scripts by using the bin/ruby_ship.bat as you would use the normal ruby command."
echo "Eg.: bin/ruby_ship.bat -v"
echo "=> ruby %RUBY_VERSION%..."

::set /p delBuild=Delete preexisting build [y/n]?: 