# Elephant In The Room
**Elephant In The Room** is an opensource multi-site news page project.

## Run the elephant!

### First, the dependencies
In order to run this project you need to have already installed:

* [Erlang](http://erlang.org/doc/installation_guide/INSTALL.html) 20.0
* [Elixir](https://elixir-lang.org/install.html) 1.6
* [PostgreSQL](https://www.postgresql.org/download/linux/ubuntu/) 10.4
* [Docker](https://docs.docker.com/install/) 17.12.1-ce
* [Docker Compose](https://docs.docker.com/compose/install/) 1.21.2
* [npm](https://docs.npmjs.com/cli/install) 6.1.0

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

The following commands need to be executed in a separate shell:

* Create elephant's database, run migrations, and seed data:
```
make create_db
```

* Start the web server:
```
make dev
```

### Populating with dummy data
You can populate the database with dummy data using `make populate_db` or `make clean_populate_db` to reset the DB and populate. Both of this will create 4 default sites, one uses `localhost` as domain, but the others use custom domains (site-2.com, site-3.com, site-4.com) so you will need to add them to your `/etc/hosts` file to be able to access them. Append the following:
```
127.0.0.1       site-2.com
127.0.0.1       site-3.com
127.0.0.1       site-4.com
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

**WARNING**: This will first destroy the database and **all** its data before it recovers the backup.

