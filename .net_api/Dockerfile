# Base for Debian ARM Linux
FROM mcr.microsoft.com/dotnet/aspnet:5.0
# Setting working directory

COPY Api/bin/Release/net5.0/publish/ App/
WORKDIR /App
ENTRYPOINT ["dotnet", "Commander.dll"]
# EXPOSE 5001