IMAGE := shouldbee/caffe

build:
	sudo docker build -t $(IMAGE) .

destroy:
	sudo docker rmi -f $(IMAGE)

exec:
	sudo docker run -it --rm --entrypoint=/bin/bash $(IMAGE)

packer:
	# Before execute this, please set environment variables
	# AWS_ACCESS_KEY_ID or AWS_ACCESS_KEY,
	# and AWS_SECRET_ACCESS_KEY or AWS_SECRET_KEY.
	packer build packer.json
