.PHONY: dev test release ops start install_frontend

create_db:
	mix ecto.create && mix ecto.migrate

dev:
	mix phx.server

install_frontend:
	cd assets/ && npm install && cd ..

start:
	mix deps.get && make install_frontend && make create_db && make dev

test:
	./rebar3 ct

ops:
	docker-compose -f docker-compose.yml up

ops_reset:
	docker-compose down --volumes
