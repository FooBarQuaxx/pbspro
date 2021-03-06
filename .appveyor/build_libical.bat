@echo off
REM Copyright (C) 1994-2017 Altair Engineering, Inc.
REM For more information, contact Altair at www.altair.com.
REM
REM This file is part of the PBS Professional ("PBS Pro") software.
REM
REM Open Source License Information:
REM
REM PBS Pro is free software. You can redistribute it and/or modify it under the
REM terms of the GNU Affero General Public License as published by the Free
REM Software Foundation, either version 3 of the License, or (at your option) any
REM later version.
REM
REM PBS Pro is distributed in the hope that it will be useful, but WITHOUT ANY
REM WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
REM PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
REM
REM You should have received a copy of the GNU Affero General Public License along
REM with this program.  If not, see <http://www.gnu.org/licenses/>.
REM
REM Commercial License Information:
REM
REM The PBS Pro software is licensed under the terms of the GNU Affero General
REM Public License agreement ("AGPL"), except where a separate commercial license
REM agreement for PBS Pro version 14 or later has been executed in writing with Altair.
REM
REM Altair’s dual-license business model allows companies, individuals, and
REM organizations to create proprietary derivative works of PBS Pro and distribute
REM them - whether embedded or bundled with other software - under a commercial
REM license agreement.
REM
REM Use of Altair’s trademarks, including but not limited to "PBS™",
REM "PBS Professional®", and "PBS Pro™" and Altair’s logos is subject to Altair's
REM trademark licensing policies.

@echo on
setlocal

call "%~dp0set_paths.bat"

cd "%BUILDDIR%"

if not defined LIBICAL_VERSION (
    echo "Please set LIBICAL_VERSION to libical version!"
    exit /b 1
)

if exist "%BINARIESDIR%\libical" (
    echo "%BINARIESDIR%\libical exist already!"
    exit /b 0
)

if not exist "%BUILDDIR%\libical-%LIBICAL_VERSION%.zip" (
    "%CURL_BIN%" -qkL -o "%BUILDDIR%\libical-%LIBICAL_VERSION%.zip" https://github.com/libical/libical/archive/v%LIBICAL_VERSION%.zip
    if not exist "%BUILDDIR%\libical-%LIBICAL_VERSION%.zip" (
        echo "Failed to download libical"
        exit /b 1
    )
)

2>nul rd /S /Q "%BUILDDIR%\libical-%LIBICAL_VERSION%"
"%UNZIP_BIN%" -q "%BUILDDIR%\libical-%LIBICAL_VERSION%.zip"
if not %ERRORLEVEL% == 0 (
    echo "Failed to extract %BUILDDIR%\libical-%LIBICAL_VERSION%.zip"
    exit /b 1
)
if not exist "%BUILDDIR%\libical-%LIBICAL_VERSION%" (
    echo "Could not find %BUILDDIR%\libical-%LIBICAL_VERSION%"
    exit /b 1
)

2>nul rd /S /Q "%BUILDDIR%\libical-%LIBICAL_VERSION%\build"
mkdir "%BUILDDIR%\libical-%LIBICAL_VERSION%\build"
cd "%BUILDDIR%\libical-%LIBICAL_VERSION%\build"

call "%VS90COMNTOOLS%vsvars32.bat"

"%CMAKE_BIN%" -DCMAKE_INSTALL_PREFIX="%BINARIESDIR%\libical" -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DUSE_32BIT_TIME_T=True ..
if not %ERRORLEVEL% == 0 (
    echo "Failed to generate makefiles for libical"
    exit /b 1
)
nmake
if not %ERRORLEVEL% == 0 (
    echo "Failed to compile libical"
    exit /b 1
)
nmake install
if not %ERRORLEVEL% == 0 (
    echo "Failed to install libical"
    exit /b 1
)

exit /b 0

