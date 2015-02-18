@echo off 
set SSL_CERT_FILE=%~dp0\shipyard\cacerts.pem
%~dp0\shipyard\win_rake.bat %* 
