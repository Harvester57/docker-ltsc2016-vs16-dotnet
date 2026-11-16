# Cf. https://hub.docker.com/_/microsoft-windows-servercore
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:1684c76f7eb7c8de20262f0779439637d1a8362cb91d3e861437397a4840a97a AS builder
SHELL ["cmd", "/S", "/C"]

# Set up environment to collect install errors.
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe
COPY Install.cmd C:/TEMP/

# Download channel for fixed install.
ADD https://aka.ms/vs/16/release/channel C:/TEMP/VisualStudio.chman

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

RUN \
  C:/TEMP/Install.cmd C:/TEMP/vs_buildtools.exe --quiet --wait --norestart --nocache \
  --channelUri C:/TEMP/VisualStudio.chman \
  --installChannelUri C:/TEMP/VisualStudio.chman \
  --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools --includeRecommended \
  --installPath C:/BuildTools

FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:1684c76f7eb7c8de20262f0779439637d1a8362cb91d3e861437397a4840a97a

LABEL org.opencontainers.image.authors="Florian Stosse <florian.stosse@gmail.com>"
LABEL org.opencontainers.image.created="2025-06-22"
LABEL org.opencontainers.image.description="Windows 10 LTSC 2019 image, with Microsoft Build Tools 2019 (v16.0) for .NET applications"
LABEL org.opencontainers.image.licenses="MIT license"

COPY --from=builder C:/BuildTools/ C:/BuildTools

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
