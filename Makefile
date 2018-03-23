.PHONY: dev test release ops start install_frontend

start:
	mix deps.get && make install_frontend && \
	make create_db && make create_roles && \
	make ops_start && \
	make dev

create_db:
	mix ecto.create && mix ecto.migrate

dev:
	mix phx.server

install_frontend:
	cd assets/ && npm install && cd ..

create_roles:
	mix run priv/repo/seeds.exs

ops: ops_reset
	docker-compose -f docker-compose.yml up

ops_reset:
	docker-compose down --volumes

ops_backup_db:
	@echo "Generation dump backup"
	mkdir -p pg_dump
	docker exec elephant_in_the_room_db pg_dumpall -h localhost -U postgres \
	 > pg_dump/backup_$$(date +"%Y%m%d%H%M%S").sql

ops_start:
	mix run priv/repo/data_generator.ex

