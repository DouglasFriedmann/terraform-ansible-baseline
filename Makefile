install:
	ansible-galaxy collection install -r requirements.yml

lint:
	ansible-lint

inventory:
	ansible-inventory -i inventory/aws_ec2.aws_ec2.yml --graph

inventory-list:
	ansible-inventory -i inventory/aws_ec2.aws_ec2.yml --list

check:
	ansible-playbook playbooks/site.yml --check --diff

apply:
	ansible-playbook playbooks/site.yml
