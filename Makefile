build:
	mkdir -p app/components
	mvn -U clean package && cp ./target/embedding-generator-deploy.jar ./app/components
