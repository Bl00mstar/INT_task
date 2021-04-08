dotnet publish -c Release
docker build -t pynet .
docker run -d -p 5001:5001 pynet
