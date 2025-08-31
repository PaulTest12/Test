.PHONY: all init up provision destroy clean

all: up provision

init:
	cd terraform && terraform init

up: init
	cd terraform && terraform apply -auto-approve

provision:
	ansible-playbook -i ansible/hosts ansible/site.yml

destroy:
	cd terraform && terraform destroy -auto-approve

clean:
	rm -f ansible/hosts
