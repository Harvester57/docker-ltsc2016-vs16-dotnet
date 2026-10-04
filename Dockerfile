# Cf. https://hub.docker.com/_/microsoft-windows-servercore
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:e10503b9a4f7faafa30aa0f5d0e8e7f7ca30a4496b3b87d61178b4d7c6815fb5 AS builder
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

FROM mcr.microsoft.com/windows/servercore:ltsc2022-amd64@sha256:e10503b9a4f7faafa30aa0f5d0e8e7f7ca30a4496b3b87d61178b4d7c6815fb5

LABEL org.opencontainers.image.authors="Florian Stosse <florian.stosse@gmail.com>"
LABEL org.opencontainers.image.created="2025-06-22"
LABEL org.opencontainers.image.description="Windows 10 LTSC 2019 image, with Microsoft Build Tools 2019 (v16.0) for .NET applications"
LABEL org.opencontainers.image.licenses="MIT license"

COPY --from=builder C:/BuildTools/ C:/BuildTools

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
