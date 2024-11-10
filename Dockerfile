# Use SDK image for build stage
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

# Copy the solution and restore dependencies
COPY dotnet-hello-world.sln .
COPY hello-world-api/hello-world-api.csproj ./hello-world-api/
RUN dotnet restore

# Copy remaining files and publish
COPY . .
WORKDIR /app/hello-world-api
RUN dotnet publish -c Release -o /app/publish

# Use runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "hello-world-api.dll"]

