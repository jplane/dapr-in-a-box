FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
COPY . /backend
RUN dotnet publish "/backend/Backend.csproj" -c Release -o /publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /host
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "Backend.dll"]
