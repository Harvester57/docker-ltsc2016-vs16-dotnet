# Cf. https://hub.docker.com/_/microsoft-windows-servercore
FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:3a1839a9dc6e4794cac893afad79d451983d3511080fad15e1f4172de57c5c42 AS builder
SHELL ["cmd", "/S", "/C"]

LABEL maintainer "florian.stosse@gmail.com"
LABEL lastupdate "2025-06-22"
LABEL author "Florian Stosse"
LABEL description "Windows 10 LTSC 2019 image, with Microsoft Build Tools 2019 (v16.0) for .NET applications"
LABEL license "MIT license"

# Set up environment to collect install errors.
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe
ADD Install.cmd C:/TEMP

# Download channel for fixed install.
ADD https://aka.ms/vs/16/release/channel C:/TEMP/VisualStudio.chman

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

RUN \
  C:/TEMP/Install.cmd C:/TEMP/vs_buildtools.exe --quiet --wait --norestart --nocache \
  --channelUri C:/TEMP/VisualStudio.chman \
  --installChannelUri C:/TEMP/VisualStudio.chman \
  --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools --includeRecommended \
  --installPath C:/BuildTools

FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:3a1839a9dc6e4794cac893afad79d451983d3511080fad15e1f4172de57c5c42

COPY --from=builder C:/BuildTools/ C:/BuildTools

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
