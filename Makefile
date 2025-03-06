build:
	mkdir -p app/components
	mvn -U clean package && cp ./target/embedding-generator-deploy.jar ./app/components

rsync:
	rsync -avz \
		./gen_docs.py ./gen_query.py \
		ec2-user@$(shell terraform -chdir="./tf" output -json | jq -r .configserver_ips.value[0]):/opt/anduin/benchmark

gen-hosts:
	terraform -chdir=./tf output -json | python gen_hosts.py | xmllint --format - | tee ./app-cloud/hosts.xml
