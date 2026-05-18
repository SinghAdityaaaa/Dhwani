clean:
	@rm -rf ./dist

build:
	@node_modules/.bin/babel --config-file ./.babelrc . -d ./dist

# GIT TASKS 
pull: ## Pull the current branch
	@git pull origin $$(git branch | grep \* | cut -d ' ' -f2) --rebase

push: ## Push the current branch
	@git push origin $$(git branch | grep \* | cut -d ' ' -f2) --force-with-lease

commit-message: ## Committing the current branch ex: make commit message ---> git commit -m "BRANCH_NAME: message"
	git commit -m "$$(git branch | grep \* | cut -d ' ' -f2): $(filter-out $@,$(MAKECMDGOALS))"

copy-local:
	@cp -rf src/locals dist/src/locals

make-build: build copy-local

deploy:
	@git pull origin $$(git branch | grep \* | cut -d ' ' -f2) --rebase
	make make-build
	pm2 restart all
