.PHONY: deps ops ops_reset ops_backup_db create_db populate_db reset_redis \
        clean_populate_db dev lint_css prod

deps:
	mix local.rebar --force
	mix local.hex --force
	mix deps.get
	cd assets/ && npm install

ops:
	docker-compose -f docker-compose.yml up

ops_reset:
	-docker-compose down --volumes

ops_backup_db:
	@echo "Generation dump backup"
	mkdir -p pg_dump
	docker exec elephant_in_the_room_db pg_dumpall -h localhost -U postgres \
		> pg_dump/backup_$$(date +"%Y%m%d%H%M%S").sql

create_db:
	mix ecto.reset
	mix ecto.migrate

populate_db:
	mix run priv/repo/data_generator.ex

reset_redis:
	docker exec -it elephant_in_the_room_redis redis-cli FLUSHDB

clean_populate_db: create_db reset_redis populate_db

dev:
	mix compile
	mix phx.server


lint_css:
	cd assets && node_modules/stylelint/bin/stylelint.js css/*

prod:
	bash -c "cd assets && npx brunch build --production"
	bash -c "MIX_ENV=prod mix phx.digest"
	bash -c "MIX_ENV=prod mix release"
	bash -c "PORT=80 _build/prod/rel/elephant_in_the_room/bin/elephant_in_the_room start"
 
attach_prod: 
	bash -c "_build/prod/rel/elephant_in_the_room/bin/elephant_in_the_room attach"

stop_prod: 
	bash -c "_build/prod/rel/elephant_in_the_room/bin/elephant_in_the_room stop"
