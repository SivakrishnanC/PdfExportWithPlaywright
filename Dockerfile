FROM mcr.microsoft.com/playwright/dotnet:v1.40.0-jammy AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/playwright/dotnet:v1.40.0-jammy AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SamplePdfExport.csproj", "."]
RUN dotnet restore "./././SamplePdfExport.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./SamplePdfExport.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./SamplePdfExport.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SamplePdfExport.dll"]