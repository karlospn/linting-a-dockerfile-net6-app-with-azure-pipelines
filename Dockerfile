#############
## Stage 1 ##
#############
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

## Copy the applications .csproj
COPY /src/WebApp/*.csproj ./src/WebApp/

## Restore packages
RUN dotnet restore "./src/WebApp/WebApp.csproj" \
	-s "https://api.nuget.org/v3/index.json" \
	--runtime linux-x64

## Copy everything else
COPY . ./

## Build the app
RUN dotnet build "./src/WebApp/WebApp.csproj" \
	-c Release \
	--runtime linux-x64 \
	--no-restore \
	/p:PublishSingleFile=true

## Run dotnet test setting the output on the /coverage folder
RUN dotnet test "./test/WebApp.Tests/WebApp.Tests.csproj" \
	--no-restore

## Publish the app
RUN dotnet publish "./src/WebApp/WebApp.csproj" \
	-c Release \
	-o /app/publish \
	--runtime linux-x64 \
	--no-restore \
	--no-build \
	--self-contained true \
	/p:PublishSingleFile=true \
	/p:PublishTrimmed=true

#############
## Stage 2 ##
#############
FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-bullseye-slim
WORKDIR /app

## Expose ports
EXPOSE 80
EXPOSE 443

## Copy artifact
COPY --from=build /app/publish .

## Set entrypoint
ENTRYPOINT ["./WebApp"]