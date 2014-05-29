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

:: Extracting ruby source
7z x %~f1 -so | 7z x -aoa -si -ttar -o"%~dp0/extracted_ruby"

for /f %%i in ('ls %~dp0/extracted_ruby') do set RUBYDIR=%%i
for /f %%i in ('echo %RUBYDIR% ^| cut -d'-' -f 2') do set RUBY_VERSION=%%i

echo "Installing ruby version %RUBY_VERSION%"

:: BUILDING RUBY
cd "%~dp0/extracted_ruby/%RUBYDIR%"
call %~dp0/extracted_ruby/%RUBYDIR%/win32/configure.bat
nmake
nmake test
nmake DESTDIR=%~dp0/../bin/win_ruby install

:: MAKING THE SCRIPT:
for /f %%i in ('ls %~dp0/../bin/win_ruby') do set RUBY_INSTALL_DIR=%%i
echo %RUBY_INSTALL_DIR%
for /f %%i in ('echo %RUBY_INSTALL_DIR% ^| cut -d'-' -f 2') do set RUBY_VERSION_DIR=%%i

echo %%~dp0\win_ruby\%RUBY_INSTALL_DIR%\bin\ruby.exe %%* > %~dp0/../bin/win_ruby.bat


:: Clean up:
cd %~dp0
rm -rf %~dp0/extracted_ruby

echo "Ruby Ship finished installing Ruby %RUBY_VERSION%!"
echo "Run scripts by using the bin/ruby_ship.sh as you would use the normal ruby command."
echo "Eg.: bin/ruby_ship.bat -v"
echo "=> ruby %RUBY_VERSION%..."

::set /p delBuild=Delete preexisting build [y/n]?: 