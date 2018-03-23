# ElephantInTheRoom

Run with:

- `make ops` to create the local database.
- `make start` to populate the database and start the web server.

## Prerequisites

In order to run this project you need to have installed:

* [Elixir](https://elixir-lang.org/)
* [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)
* [npm](https://www.npmjs.com/)

## Installing

To setup the database, first run:

```
$ make ops
```

Then, run:

```
$ make start
```

To install all the dependencies and start the project.
You can visit [`localhost:4000`](http://localhost:4000) from your browser to see it working.

## Generate test data

You can run:

```
$ make ops_start
```

To populate the database with sample data.
