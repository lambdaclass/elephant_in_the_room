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
* [postgresql:10.4](https://www.postgresql.org/download/linux/ubuntu/), in both the database server and in the client.

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

### Backup

The backup can be generated sending a POST request `/admin/backup/do_backup` or in the admin panel `/admin/backup` pressing the botton `backup now`. After the backup is generated it can be downloaded to pressing the `download latest backup` that will appear when the backup generation process ends.

The restoration of the database is manual, it can be done this way:

```bash
export PGPASSWORD=<db_password> && \
psql -h <db_host>  -U <db_user> -c "drop database <database_name>; create database <database_name>;" && \
psql -h <db_host>  -U <db_user> -v ON_ERROR_STOP=1 <database_name> < \
  <location_of_backup>.sql
```

This will first destroy the database and **all** its data before it applies the backup.

