.PHONY: help demo_server create_db populate_db install_frontend \
        ops ops_reset ops_backup_db deps lint_css prod

help:
	@echo "To start a demo sever run in two separated shells:"
	@echo "1) make demo_db"
	@echo "2) make demo_server"
	@echo "For development:"
	@echo "- dev: runs the phoenix server"
	@echo "- ops: runs the database"

deps:
	mix local.rebar --force
	mix local.hex --force
	mix deps.get
	cd assets/ && npm install

demo_server: install_frontend create_db populate_db dev

demo_db: ops_reset ops

create_db:
	mix ecto.reset
	mix ecto.migrate

populate_db:
#   create roles in database
	mix run priv/repo/seeds.exs
#   create users, and random posts
	mix run priv/repo/data_generator.ex

clean_init_db: create_db populate_db

dev:
	mix compile
	mix phx.server

install_frontend:
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

lint_css:
	cd assets && node_modules/stylelint/bin/stylelint.js css/*

prod:
	mix deps.get --only prod
	bash -c "MIX_ENV=prod mix compile"
	bash -c "cd assets && npx brunch build --production"
	mix phx.digest
	bash -c "MIX_ENV=prod PORT=80 iex -S mix phx.server"
