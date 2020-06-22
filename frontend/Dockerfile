FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
COPY . /frontend
RUN dotnet publish "/frontend/Frontend.csproj" -c Release -o /publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /host
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "Frontend.dll"]
