Wordpress <3 Docker
=====================

Install any Wordpress site in seconds using Docker. It allowsd support for configuring a default custom theme at boot time, as well as volumes for loading pre-existing data.

Software Requirements
----------------------

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

If you're on a macOS or Windows machine, Docker Compose comes bundled with the Docker Application. On Linux, additional [installation steps](https://docs.docker.com/compose/install/) may be required.

Setting up the project
----------------------
### Environment Variables
Before you start the project's containers, you need to configure the environment variables the containers will use for an specific environment.

You'll find 2 files named `.env.wp.example` and `.env.db.example` with boilerplate variables. Rename these files to `.env.wp` and `.env.db` respectively and configure all the environment variables you need.

Below is a list of all the environment variables that require configuration:

#### For the WordPress Service
| Name                   | Description                                                              |
|------------------------|--------------------------------------------------------------------------|
| `WORDPRESS_VERSION`      | the version of WordPress to work with (default to 4.7)                   |
| `WORDPRESS_LOCALE`       | the language bundled with WordPress (defaults to `en_US`)                |
| `WORDPRESS_DB_USER`      | the database user for database access. **It must match `MYSQL_USER`**        |
| `WORDPRESS_DB_NAME`      | the database name. **It must match `MYSQL_DATABASE`**                       |
| `WORDPRESS_DB_PASSWORD`  | the DB user's password. **It must match `MYSQL_PASSWORD`**                     |
| `WORDPRESS_TABLE_PREFIX` | the database table prefix (defaults to `wp_`)                          |
| `WP_SITE_URL`            | the website's URL used to generate links and rewrite rules               |
| `WP_SITE_TITLE`          | the website's title                                                      |
| `WP_ADMIN_USER`          | the name of the initial admin user                              |
| `WP_ADMIN_EMAIL`         | the admin user's email address                                           |
| `WP_ADMIN_PASSWORD`      | the admin user's account password                                        |

#### For the Database Service
| Name                | Description                                                              |
|---------------------|--------------------------------------------------------------------------|
| `MYSQL_ROOT_PASSWORD` | the password for the service's `root` user (make this a strong password) |
| `MYSQL_DATABASE`      | the name of the database to create                                       |
| `MYSQL_USER`          | the user with access privileges to `MYSQL_DATABASE`                        |
| `MYSQL_PASSWORD`      | the password for MYSQL_USER                                              |

### Cloning Custom Theme
This project allows you to clone a pre-existing theme using git and setting it up as your site's default theme, so you don't have to configure it every time you start your site's container.

To take advantage of this, define the following environment variables for the wordpress container:

| Name                   | Description                                                              |
|------------------------|--------------------------------------------------------------------------|
| `WORDPRESS_CUSTOM_THEME_NAME`      | The theme's name. This will be used as the folder name of theme                  |
| `WORDPRESS_CUSTOM_THEME_URL`       | The Theme's repository URL                |

You can include your deployment SSH keys for cloning the theme in the `/.ssh` folder at the root of the project.

Currently, this feature only supports themes versioned with `git`. If you want to use a theme from Wordpress or a third-party theme, you can install and configure it manually.

### Setting up the containers
Clone this repository into any path in your machine. `cd` into that location and run:

```bash
$ cd /path/to/project
$ docker-compose up
```
This will start all the services defined in the `docker-compose.yml` file at the root of the project. This process may take several minutes when running it for the first time.

When finished, you can access your freshly-baked Wordpress site at `http://localhost:8080` in your machine. Two folders will be automatically created when the boot finishes:

```bash
$ tree -d -L 2
.
├── db_data
└── wp-content
```

* `db_data` is a Docker Volume containing a database backup with all the site's configuration.
* `wp-content` is a Docker volume mapped to the `wp-content` folder of the WordPress container, where you can customize your WordPress installation.

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

Persisting Site configuration
--------------------------------------
This project is currently ignoring the `db_data` and `wp-content` folders that are used as the container's volumes. If you want to reproduce your wordpress site on multiple machines, you can add them to source control by removing them from the `.gitignore` file and adding them to the repository.

If you think the above solution is unrefined, you can just zip these folders and use git LFS or any other cloud persistence method such as AWS S3 and then download the files however you see fit.

Authors
--------
Andrés Osorio <androideosorio@me.com>.

Please feel free to contribute By creating a pull request. I love Wordpress and Docker, and always wanted to use them together in a scalable way. Any improvement is welcome.