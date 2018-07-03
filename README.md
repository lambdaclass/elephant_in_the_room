# Elephant In The Room
**Elephant In The Room** is an opensource multi-site news page project.

## Run the elephant!

### First, the dependencies
In order to run this project you need to have already installed:

* [Erlang: 20.0](http://erlang.org/doc/installation_guide/INSTALL.html)
* [Elixir: 1.6 ](https://elixir-lang.org/install.html)
* [Docker: 17.12.1-ce](https://docs.docker.com/install/)
* [Docker Compose: 1.21.2](https://docs.docker.com/compose/install/)
* [npm: 6.1.0](https://docs.npmjs.com/cli/install)

### How to run the server locally
Run the website with the following commands:

* Install project dependencies:
```
make deps
```

* Start the database server:
```
make ops
```

The following commands need to be executed in separate shells.

* Create elephant's database, run migrations, and fill with data:
```
make clean_init_db
```

* Start the web server:
```
make dev
```
