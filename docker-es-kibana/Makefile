up: 
	docker-compose -f docker-compose.yml  up -d --build --force-recreate

down:
	docker-compose -f docker-compose.yml  down

restart:
	$(MAKE) down up

ps:
	docker-compose -f docker-compose.yml  ps