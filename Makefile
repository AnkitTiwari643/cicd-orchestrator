test:
	npm --prefix app install
	npm --prefix app test

build:
	docker build -t cicd-orchestrator:local ./app

version-show:
	cat VERSION
