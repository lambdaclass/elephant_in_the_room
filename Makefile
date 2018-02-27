.PHONY: dev test release ops

dev:
	mix ecto.create && mix ecto.migrate && mix phx.server

test:
	./rebar3 ct

ops:
	docker-compose -f docker-compose.yml up

ops_reset:
	docker-compose -f docker-compose.yml down
