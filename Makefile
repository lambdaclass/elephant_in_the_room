.PHONY: help demo_server create_db populate_db install_frontend \
        ops ops_reset ops_backup_db deps

help:
	@echo "To start a demo sever run in two separated shells:"
	@echo "1) make demo_db"
	@echo "2) make demo_server"
	@echo "For development:"
	@echo "- dev: runs the phoenix server"
	@echo "- ops: runs the database"

deps:
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

ops: ops_reset
	docker-compose -f docker-compose.yml up

ops_reset:
	-docker-compose down --volumes

ops_backup_db:
	@echo "Generation dump backup"
	mkdir -p pg_dump
	docker exec elephant_in_the_room_db pg_dumpall -h localhost -U postgres \
	 > pg_dump/backup_$$(date +"%Y%m%d%H%M%S").sql



