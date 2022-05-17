# This Dockerfile creates an image that:
# - Has the correct MTU setting for networking from inside the container to work.
# - Has Visual Studio 2019 Build Tools installed.
# - Has MSVC 14.29 and clang 14.0 installed
# - Has msys2 + git, curl, zip, unzip installed.
# - Has Python 3.9 installed.
# - Has Bazelisk 0.11 installed.
# TODO: Consider replacing "ADD $URI $DEST" with "Invoke-WebRequest -Method Get -Uri $URI -OutFile $DEST"
# Use the latest Windows Server Core image.

FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $VerbosePreference = 'Continue';"]

## TODO: Workaround until bug is fixed.
RUN netsh interface ipv4 set subinterface \"vEthernet (Ethernet)\" mtu=1460 store=persistent

RUN md C:\TEMP
RUN md C:\TMP

RUN (New-Object Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_community.exe', 'C:\TEMP\vs_community.exe');
# Install Visual Studio 2019 Build Tools.
SHELL ["cmd", "/S", "/C"]
RUN C:\TEMP\vs_community.exe \
        --quiet --wait --norestart --nocache \
        --add Microsoft.VisualStudio.Component.CoreEditor \
        --add Microsoft.VisualStudio.Workload.CoreEditor \
        --add Microsoft.VisualStudio.Component.NuGet \
        --add Microsoft.Net.Component.4.6.1.TargetingPack \
        --add Microsoft.VisualStudio.Component.Roslyn.Compiler \
        --add Microsoft.VisualStudio.Component.Roslyn.LanguageServices \
        --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions \
        --add Microsoft.Net.Component.4.8.SDK \
        --add Microsoft.Net.Component.4.7.2.TargetingPack \
        --add Microsoft.VisualStudio.Component.TypeScript.4.3 \
        --add Microsoft.VisualStudio.Component.JavaScript.TypeScript \
        --add Microsoft.Component.MSBuild \
        --add Microsoft.VisualStudio.Component.TextTemplating \
        --add Microsoft.VisualStudio.Component.Debugger.JustInTime \
        --add Component.Microsoft.VisualStudio.LiveShare \
        --add Microsoft.VisualStudio.Component.IntelliCode \
        --add Microsoft.Net.Component.4.8.TargetingPack \
        --add Microsoft.VisualStudio.Component.VC.CoreIde \
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
        --add Microsoft.VisualStudio.Component.Graphics.Tools \
        --add Microsoft.VisualStudio.Component.VC.DiagnosticTools \
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 \
        --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest \
        --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core \
        --add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions.CMake \
        --add Microsoft.VisualStudio.Component.VC.CMake.Project \
        --add Microsoft.VisualStudio.Component.VC.ATL \
        --add Microsoft.VisualStudio.Component.VC.TestAdapterForBoostTest \
        --add Microsoft.VisualStudio.Component.VC.TestAdapterForGoogleTest \
        --add Microsoft.VisualStudio.Component.VC.ATLMFC \
        --add Microsoft.VisualStudio.Component.VC.ASAN \
        --add Microsoft.VisualStudio.Component.VC.Modules.x86.x64 \
        --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset \
        --add Microsoft.VisualStudio.Component.VC.Llvm.Clang \
        --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang \
        --add Microsoft.VisualStudio.Workload.NativeDesktop \
        --add Microsoft.VisualStudio.Component.VC.14.29.x86.x64 \
        --add Microsoft.VisualStudio.Component.VC.CLI.Support \
        --add Microsoft.Net.Component.4.6.1.SDK \
        --add Microsoft.VisualStudio.Component.Windows10SDK.20348 \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $VerbosePreference = 'Continue';"]

# Install 7-Zip and add it to the path.
RUN (New-Object Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1801-x64.msi', '7z.msi'); \
    Start-Process msiexec.exe -ArgumentList \"/i 7z.msi /qn /norestart /log C:\\TEMP\\7z_install_log.txt\" -wait; \
    Remove-Item .\7z.msi;

# Install msys2, and add some extra tools.
RUN (New-Object Net.WebClient).DownloadFile( \
         'http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20200602.tar.xz', \
         'msys2.tar.xz'); \
    Start-Process -FilePath \"C:\Program Files\7-Zip\7z.exe\" -ArgumentList 'x msys2.tar.xz -oC:\TEMP\msys2.tar' -Wait; \
    Start-Process -FilePath \"C:\Program Files\7-Zip\7z.exe\" -ArgumentList 'x C:\TEMP\msys2.tar -oC:\tools' -Wait; \
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';C:\tools\msys64;C:\tools\msys64\usr\bin\'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'Machine');

# Install clang.
RUN (New-Object Net.WebClient).DownloadFile( \
         'https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/LLVM-14.0.0-win64.exe', \
         'LLVM.exe'); \
    Start-Process -FilePath \"C:\Program Files\7-Zip\7z.exe\" -ArgumentList 'x LLVM.exe -oC:\tools\llvm' -Wait; \
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';C:\tools\llvm\bin'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'Machine');


# Disable signature checking on pacman because we cannot initialize the keyring
RUN Add-Content -Path C:\tools\msys64\etc\pacman.d\mirrorlist.mingw32 -Value 'SigLevel = Never'
RUN Add-Content -Path C:\tools\msys64\etc\pacman.d\mirrorlist.mingw64 -Value 'SigLevel = Never'
RUN Add-Content -Path C:\tools\msys64\etc\pacman.d\mirrorlist.msys -Value 'SigLevel = Never'

# Install pacman packages.
RUN pacman --noconfirm -Syy git curl zip unzip patch

# Install Python 3.9.7
ENV PYTHON_VERSION 3.9.7

RUN $url = ('https://www.python.org/ftp/python/{0}/python-{0}-amd64.exe' -f $env:PYTHON_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	(New-Object Net.WebClient).DownloadFile($url, 'C:\tmp\pyinstall.exe'); \
	\
	Write-Host 'Installing...'; \
        Start-Process -FilePath \"C:\tmp\pyinstall.exe\" -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1 TargetDir=C:\Python39' -Wait; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  python --version'; C:\python39\python.exe --version; \
	\
	Write-Host 'Verifying pip install ...'; \
	C:\python39\python.exe -m pip --version; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item C:\tmp\pyinstall.exe -Force; \
	\
	Write-Host 'Complete.';

# Install the pip packages
RUN python -m pip install --ignore-installed --force-reinstall --upgrade \
    setuptools packaging\
    pyreadline tf-estimator-nightly tb-nightly backports.weakref==1.0rc1 \
    protobuf absl-py portpicker gast termcolor astor h5py numpy \
    scipy keras-nightly keras_applications keras_preprocessing

RUN \
  Add-Type -AssemblyName \"System.IO.Compression.FileSystem\"; \
  $zulu_url = \"https://cdn.azul.com/zulu/bin/zulu8.28.0.1-jdk8.0.163-win_x64.zip\"; \
  $zulu_zip = \"c:\\temp\\zulu8.28.0.1-jdk8.0.163-win_x64.zip\"; \
  $zulu_extracted_path = \"c:\\temp\\\" + [IO.Path]::GetFileNameWithoutExtension($zulu_zip); \
  $zulu_root = \"c:\\openjdk\"; \
  (New-Object Net.WebClient).DownloadFile($zulu_url, $zulu_zip); \
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zulu_zip, \"c:\\temp\"); \
  Move-Item $zulu_extracted_path -Destination $zulu_root; \
  Remove-Item $zulu_zip; \
  $env:PATH = [Environment]::GetEnvironmentVariable(\"PATH\", \"Machine\") + \";${zulu_root}\\bin\"; \
  [Environment]::SetEnvironmentVariable(\"PATH\", $env:PATH, \"Machine\"); \
  $env:JAVA_HOME = $zulu_root; \
  [Environment]::SetEnvironmentVariable(\"JAVA_HOME\", $env:JAVA_HOME, \"Machine\")

# Environment variables to work around the msys issues
ENV MSYS_NO_PATHCONV 1
ENV MSYS2_ARG_CONV_EXCL *

# See https://docs.microsoft.com/en-us/visualstudio/releases/2019/history for the mapping
ENV BAZEL_VC_FULL_VERSION 14.29.30133

# Make sure path to MSVC tools is available to Bazel
ENV BAZEL_VC "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC"

# Install bazelisk
RUN md C:\tools\bazel
RUN (New-Object Net.WebClient).DownloadFile( \
         'https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-windows-amd64.exe', \
         'C:\tools\bazel\bazel.exe'); \
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';C:\tools\bazel'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, 'Machine');

# Restore default shell for Windows containers.
SHELL ["cmd.exe", "/s", "/c"]
# Default to PowerShell if no other command specified.
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"] \
	\
	Write-Host 'Verifying pip install ...'; \
	python -m pip --version; \
	\
	Write-Host 'Complete.';
