FROM mcr.microsoft.com/windows/servercore:10.0.17763.5329-amd64 AS base

ENV NIPM_240 https://download.ni.com/support/nipkg/products/ni-package-manager/installers/NIPackageManager24.0.0.exe

WORKDIR /users/public/downloads
#COPY ./resources/NIPackageManager24.0.0.exe ./
#RUN takeown /F "NIPackageManager24.0.0.exe" >nul 2>nul
RUN powershell -Command Invoke-WebRequest $Env:NIPM_240 -OutFile 'NIPackageManager24.0.0.exe' 
RUN NIPackageManager24.0.0.exe --passive --accept-eulas --prevent-reboot
RUN del NIPackageManager24.0.0.exe

FROM base AS addfeed

ENV IVI_COMPLIANCE_PACKAGE https://download.ni.com/support/nipkg/products/ni-i/ni-icp/24.0/released
ENV IVI_COMPLIANCE_PACKAGE_CRITICAL https://download.ni.com/support/nipkg/products/ni-i/ni-icp/24.0/released-critical

ENV VISA_PACKAGE https://download.ni.com/support/nipkg/products/ni-v/ni-visa/24.0/released
ENV VISA_PACKAGE_CRITICAL https://download.ni.com/support/nipkg/products/ni-v/ni-visa/24.0/released-critical

WORKDIR "/Program Files/National Instruments/NI Package Manager"

RUN nipkg.exe feed-add --name="ni-icp-2024 Q1-released" %IVI_COMPLIANCE_PACKAGE% &&\
    nipkg.exe feed-add --name="ni-icp-2024 Q1-released-critical" %IVI_COMPLIANCE_PACKAGE_CRITICAL% &&\
    nipkg.exe update &&\
    nipkg.exe upgrade

RUN nipkg.exe feed-add --name="ni-visa-2024 Q1-released" %VISA_PACKAGE% &&\
    nipkg.exe feed-add --name="ni-visa-2024 Q1-released-critical" %VISA_PACKAGE_CRITICAL% &&\
    nipkg.exe update &&\
    nipkg.exe upgrade

FROM addfeed AS install-icp
RUN nipkg.exe install --accept-eulas --yes ni-icp & exit 0

#FROM final AS install-visa
#RUN nipkg.exe install --accept-eulas --yes ni-visa & exit 0

#WORKDIR "/Program Files (x86)/National Instruments/LabVIEW 2019"
#COPY labview.ini LabVIEW.ini