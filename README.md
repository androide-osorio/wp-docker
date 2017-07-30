Wordpress <3 Docker
=====================

Install any Wordpress site in seconds using Docker.

Software Requirements
----------------------
This project uses the Docker Platform for managing and starting the required services which the site was built upon.

Please go to [Docker's site](https://www.docker.com/products/docker) to download Docker and follow the installation instructions to install Docker in your machine. No other requirements are necessary for running this project.

Once you have Docker installed, make sure the Docker daemon is up and running:

```bash
$ docker --version
```
If you're on a macOS or Windows machine, you have to boot the Docker application first. For Linux users, no action is required since Docker Daemon boots at startup.

Now make sure you have a running version of docker Compose:
```bash
$ docker-compose --version
```

If you're on a macOS or Windows machine, Docker Compose comes bundled with the Docker Application. On Linux, more [installation steps](https://docs.docker.com/compose/install/) may be required.

Setting up the project
----------------------
### Environment Variables
Before you start the project's containers, you need to configure the environment variables the containers will use for an specific environment.

You'll find 2 files named `.env.wordpress.example` and `.env.mysql.example` with boilerplate variables. Rename these files to `.env.wordpress` and `.env.mysql` respectively and configure all the environment variables.

Below is a list of all the environment variables that need configuration:

#### For the WordPress Service
| Name                   | Description                                                              |
|------------------------|--------------------------------------------------------------------------|
| WORDPRESS_VERSION      | the version of WordPress to work with (default to 4.7)                   |
| WORDPRESS_LOCALE       | the language bundled with WordPress (defaults to `en_US`)                |
| WORDPRESS_DB_USER      | the database's user for database access (must match `MYSQL_USER`)        |
| WORDPRESS_DB_NAME      | the database's name  (must match `MYSQL_DATABASE`)                       |
| WORDPRESS_DB_PASSWORD  | the DB user's password (must match `MYSQL_PASSWORD`)                     |
| WORDPRESS_TABLE_PREFIX | the database's table prefix (defaults to `wp_`)                          |
| WP_SITE_URL            | the website's URL used to generate links and rewrite rules               |
| WP_SITE_TITLE          | the website's title                                                      |
| WP_ADMIN_USER          | the name of the initial administrative user                              |
| WP_ADMIN_EMAIL         | the admin user's email address                                           |
| WP_ADMIN_PASSWORD      | the admin user's account password                                        |

#### For the Database Service
| Name                | Description                                                              |
|---------------------|--------------------------------------------------------------------------|
| MYSQL_ROOT_PASSWORD | the password for the service's `root` user (make this a strong password) |
| MYSQL_DATABASE      | the name of the database to create                                       |
| MYSQL_USER          | the user with access privileges to MYSQL_DATABASE                        |
| MYSQL_PASSWORD      | the password for MYSQL_USER                                              |

Environment files for development environment are already provided with some default values (`.env.wordpress.dev` and `.env.mysql.dev`). If you're on a development environment, please rename these files as described above. Otherwise, make sure to **delete** these files when deploying to a production environment.


### Setting up the containers
When you're ready with the software requirements, clone this repository into any path in you machine. `cd` into that location and run:

```bash
$ cd /path/to/project
$ docker-compose up
```
This will start all the services defined in the `docker-compose.yml` file at the root of the project. The process may take a few minutes.

When finished, you can access the Marketing site at `http://localhost:8080` in your machine. Two folders will be automatically created when the boot finishes:

```bash
$ tree -d -L 2
.
├── db_data
└── wp
```

* `db_data` is a Docker Volume containing a database backup with all the site's configuration.
* `wp` is a Docker volume mapped to the `wp-content` folder of the WordPress container, it's here you can customize the WordPress installation.

**Important Note:** the `docker-compose up` command should be executed when setting up the project *for the first time*. For starting and shutting down the containers of an existing project, follow the instructions below.

Booting and Shutting down
-------------------------
If you already set up this project for the first time using the `docker-compose up` command, you can start the provisioned containers by running:

```bash
$ docker-compose start
```

When you're done with your changes, you can stop all the containers by running:

```bash
$ docker-compose stop
```

You can also run these commands over a specific container of this project by providing the container's name after the command:

```bash
$ docker-compose restart mysql_1
```

If you need to see a list of all the created containers in this project, use the `ps` command, which will output a table listing all the containers, along with their metadata:

```bash
$ docker-compose ps -a
```

Rebuilding and Re-creating containers
--------------------------------------
If you perform changes to this project's `Dockerfile`, you will have to rebuild the Container image used by the `wordpress` services for your changes to take effect. To do this, first stop and remove any container you have created before by running:

```bash
$ docker-compose down
```

Next, rebuild the container by running:
```bash
$ docker-compose build
```

The process may take several minutes to complete. When finished, you can re-create the containers using `docker-compose up`

Authors
--------
Andrés Osorio <andresf.osorio23@gmail.com>.

Copyright &copy;2017 WOW Reports
