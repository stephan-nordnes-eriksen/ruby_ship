@echo off

:: VERIFY PARAMETERS
if [%1]==[] (
	echo No arguments supplied
    echo Usage: win_compile_ruby.sh /path/to/ruby_source.tar.gz
    exit /B
)

:: REQUIRE COMPILER
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

echo Compiling and installing Ruby

:: PRE INSTALL CLEANUP
::rm -rf %~dp0/../bin/win_ruby
rm -rf %~dp0/extracted_ruby
mkdir %~dp0/extracted_ruby
::mkdir %~dp0/../bin/win_ruby

:: UNZIP SOURCE
7z x %~f1 -so | 7z x -aoa -si -ttar -o"%~dp0/extracted_ruby"

:: GET RUBY VERSION AND DIRECTORY
for /f %%i in ('ls %~dp0/extracted_ruby') do set RUBYDIR=%%i
for /f %%i in ('echo %RUBYDIR% ^| cut -d'-' -f 2') do set RUBY_VERSION=%%i

echo ############################
echo Ruby Ship is Installing Ruby version %RUBY_VERSION%
echo ############################


::EDITING ext/Setup FILE FOR WINDOWS
::%~dp0\win_helpers\fart.exe -- %~dp0extracted_ruby\%RUBYDIR%\ext\Setup #zlib zlib
::%~dp0\win_helpers\fart.exe -- %~dp0extracted_ruby\%RUBYDIR%\ext\Setup #Win32API Win32API
::%~dp0\win_helpers\fart.exe -- %~dp0extracted_ruby\%RUBYDIR%\ext\Setup #win32ole win32ole

:: WINDOWS SPECIFIC ENV VARIABLES
SET LIB=%LIB%; %~dp0zlib\lib
SET INCLUDE=%INCLUDE%; %~dp0zlib\include
		


:: BUILDING RUBY
cd "%~dp0/extracted_ruby/%RUBYDIR%"
call %~dp0/extracted_ruby/%RUBYDIR%/win32/configure.bat --enable-load-relative --prefix=%~dp0/../bin/shipyard/win_ruby
nmake
nmake test
nmake install

:: SETTING UP REFERENCE DIRECTORIES
for /f %%i in ('ls %~dp0/../bin/shipyard/win_ruby/include') do set RUBY_INSTALL_DIR=%%i
for /f %%i in ('echo %RUBY_INSTALL_DIR% ^| cut -d'-' -f 2') do set RUBY_VERSION_DIR=%%i
for /f %%i in ('ls %~dp0/../bin/shipyard/win_ruby/lib/ruby/%RUBY_VERSION_DIR% ^| FindStr /mswin/') do set RUBY_BINARY_VERSION_DIR=%%i

cd "%~dp0/../.."

:: MAKING THE SCRIPT:

echo %RUBY_INSTALL_DIR%

:: BUILDING RUBY SHIP WRAPPERS:
:: ruby_ship
echo @echo off > %~dp0/../bin/ruby_ship.bat
echo %%~dp0\shipyard\win_ruby.bat %%* >> %~dp0/../bin/ruby_ship.bat

:: ruby_ship_gem
echo @echo off > %~dp0/../bin/ruby_ship_gem.bat
echo %%~dp0\shipyard\win_gem.bat %%* >> %~dp0/../bin/ruby_ship_gem.bat

:: ruby_ship_erb
echo @echo off > %~dp0/../bin/ruby_ship_erb.bat
echo %%~dp0\shipyard\win_erb.bat %%* >> %~dp0/../bin/ruby_ship_erb.bat

:: ruby_ship_irb
echo @echo off > %~dp0/../bin/ruby_ship_irb.bat
echo %%~dp0\shipyard\win_irb.bat %%* >> %~dp0/../bin/ruby_ship_irb.bat

:: ruby_ship_rake
echo @echo off > %~dp0/../bin/ruby_ship_rake.bat
echo %%~dp0\shipyard\win_rake.bat %%* >> %~dp0/../bin/ruby_ship_rake.bat

:: ruby_ship_rdoc
echo @echo off > %~dp0/../bin/ruby_ship_rdoc.bat
echo %%~dp0\shipyard\win_rdoc.bat %%* >> %~dp0/../bin/ruby_ship_rdoc.bat

:: ruby_ship_ri
echo @echo off > %~dp0/../bin/ruby_ship_ri.bat
echo %%~dp0\shipyard\win_ri.bat %%* >> %~dp0/../bin/ruby_ship_ri.bat

:: ruby_ship_testrb
echo @echo off > %~dp0/../bin/ruby_ship_testrb.bat
echo %%~dp0\shipyard\win_testrb.bat %%* >> %~dp0/../bin/ruby_ship_testrb.bat

:: ruby_ship_bundle
echo @echo off > %~dp0/../bin/ruby_ship_bundle.bat
echo %%~dp0\shipyard\win_bundle.bat %%* >> %~dp0/../bin/ruby_ship_bundle.bat

:: ruby_ship_bundler
echo @echo off > %~dp0/../bin/ruby_ship_bundler.bat
echo %%~dp0\shipyard\win_bundler.bat %%* >> %~dp0/../bin/ruby_ship_bundler.bat


:: MAKING THE OS SPECIFIC SCRIPTS:
:: OS_ruby
echo @echo off > %~dp0/../bin/shipyard/win_ruby.bat
echo %%~dp0\win_ruby\bin\ruby.exe %%* >> %~dp0/../bin/shipyard/win_ruby.bat

:: gem command script:
echo @echo off > %~dp0/../bin/shipyard/win_gem.bat
echo %%~dp0\win_ruby\bin\gem.bat %%* >> %~dp0/../bin/shipyard/win_gem.bat

:: erb command script:
echo @echo off > %~dp0/../bin/shipyard/win_erb.bat
echo %%~dp0\win_ruby\bin\erb.bat %%* >> %~dp0/../bin/shipyard/win_erb.bat

:: irb command script:
echo @echo off > %~dp0/../bin/shipyard/win_irb.bat
echo %%~dp0\win_ruby\bin\irb.bat %%* >> %~dp0/../bin/shipyard/win_irb.bat

:: rake command script:
echo @echo off > %~dp0/../bin/shipyard/win_rake.bat
echo %%~dp0\win_ruby\bin\rake.bat %%* >> %~dp0/../bin/shipyard/win_rake.bat

:: rdoc command script:
echo @echo off > %~dp0/../bin/shipyard/win_rdoc.bat
echo %%~dp0\win_ruby\bin\rdoc.bat %%* >> %~dp0/../bin/shipyard/win_rdoc.bat

:: ri command script:
echo @echo off > %~dp0/../bin/shipyard/win_ri.bat
echo %%~dp0\win_ruby\bin\ri.bat %%* >> %~dp0/../bin/shipyard/win_ri.bat

:: testrb command script:
echo @echo off > %~dp0/../bin/shipyard/win_testrb.bat
echo %%~dp0\win_ruby\bin\testrb.bat %%* >> %~dp0/../bin/shipyard/win_testrb.bat

:: bundle command script:
echo @echo off > %~dp0/../bin/shipyard/win_bundle.bat
echo %%~dp0\win_ruby\bin\bundle.exe %%* >> %~dp0/../bin/shipyard/win_bundle.bat

:: bundler command script:
echo @echo off > %~dp0/../bin/shipyard/win_bundler.bat
echo %%~dp0\win_ruby\bin\bundler.bat %%* >> %~dp0/../bin/shipyard/win_bundler.bat


:: Clean up:
cd %~dp0
rm -rf %~dp0/extracted_ruby

echo Ruby Ship finished installing Ruby %RUBY_VERSION%!
echo Run scripts by using the bin/ruby_ship.bat as you would use the normal ruby command.
echo Eg.: bin/ruby_ship.bat -v
echo => ruby %RUBY_VERSION%...
