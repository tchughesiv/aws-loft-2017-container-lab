# LAB 3: Deconstructing an application into microservices

In this lab you will deconstruct an application into microservices, creating a multi-container application. In this process we explore the challenges of networking, storage and configuration.

This lab should be performed on **YOUR ASSIGNED AWS VM** as `ec2-user` unless otherwise instructed.

NOTE: In the steps below we use `vi` to edit files.  If you are unfamiliar this is a [good beginner's guide](https://www.howtogeek.com/102468/a-beginners-guide-to-editing-text-files-with-vi/).

Expected completion: 20-30 minutes

## Decompose the application

In the previous lab we created an "all-in-one" application. Let's enter the container and explore.

```bash
$ docker exec -it bigapp /bin/bash
```

### Services

From the container namespace list the log directories.

```bash
[CONTAINER_NAMESPACE]# ls -l /var/log/
```

We see `httpd` and `mariadb`. These are the services that make up the Wordpress application.

### Ports

We saw in the Dockerfile that port 80 was exposed. This is for the web server. Let's look at the mariadb logs for the port the database uses:

```bash
[CONTAINER_NAMESPACE]# grep port /var/log/mariadb/mariadb.log
```

This shows port 3306 is used.

### Storage

#### Web server

The Wordpress tar file was extracted into `/var/www/html`. List the files.

```bash
[CONTAINER_NAMESPACE]# ls -l /var/www/html
```

These are sensitive files for our application and it would be unfortunate if changes to these files were lost. Currently the running container does not have any associated "volumes", which means that if this container dies all changes will be lost. This mount point in the container should be backed by a "volume". Later in this lab we'll use a host directory backed "volume" to make sure these files persist.

#### Database

Inspect the `mariadb.log` file to discover the database directory.
```bash
[CONTAINER_NAMESPACE]# grep databases /var/log/mariadb/mariadb.log
```

Again, we have found some files that are in need of some non-volatile storage. The `/var/lib/mysql` should also be mounted to persistent storage on the host.

Now that we've inspected the container stop and remove it. `docker ps -ql` prints the ID of the latest created container.  First you will need to exit the container.
```bash
[CONTAINER_NAMESPACE]# exit
$ docker stop $(docker ps -ql)
$ docker rm $(docker ps -ql)
```

## Create the Dockerfiles

Now we will develop the two images. Using the information above and the Dockerfile from Lab 2 as a guide we will create Dockerfiles for each service. For this lab we have created a directory for each service with the required files for the service. Please explore these directories and check out the contents and checkout the startup scripts.
```bash
$ mkdir ~/workspace
$ cd ~/workspace
$ cp -R ~/rh-container-lab/labs/lab3/mariadb .
$ cp -R ~/rh-container-lab/labs/lab3/wordpress .
$ ls -lR mariadb
$ ls -lR wordpress
```

### MariaDB Dockerfile

1. In a text editor create a file named `Dockerfile` in the `mariadb` directory. (There is a reference file in the `mariadb` directory if needed)

        $ vi mariadb/Dockerfile

1. Add a `FROM` line that uses a specific image tag. Also add `MAINTAINER` information.

        FROM registry.access.redhat.com/rhel7:7.4-129
        MAINTAINER Student <student@example.com>

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache.

        RUN yum -y install --disablerepo "*" --enablerepo rhel-7-server-rpms \
              mariadb-server openssl psmisc net-tools hostname && \
            yum clean all

1. Add the dependent scripts and modify permissions to support non-root container runtime.

        ADD scripts /scripts
        RUN chmod 755 /scripts/* && \
            MARIADB_DIRS="/var/lib/mysql /var/log/mariadb /run/mariadb" && \
            chown -R mysql:0 ${MARIADB_DIRS} && \
            chmod -R g=u ${MARIADB_DIRS}

1. Add an instruction to expose the database port.

        EXPOSE 3306

1. Add a `VOLUME` instruction. This ensures data will be persisted even if the container is lost.

        VOLUME /var/lib/mysql /var/log/mariadb /run/mariadb

1. Switch to a non-root `USER`.

        USER mysql

1. Finish by adding the `CMD` instruction.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the file and exit the editor.

### Wordpress Dockerfile

Now we'll create the Wordpress Dockerfile. (As before, there is a reference file in the `wordpress` directory if needed)

1. Using a text editor create a file named `Dockerfile` in the `wordpress` directory.

        $ vi wordpress/Dockerfile

1. Add a `FROM` line that uses a specific image tag. Also add `MAINTAINER` information.

        FROM registry.access.redhat.com/rhel7:7.4-129
        MAINTAINER Student <student@example.com>

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache.

        RUN yum -y install --disablerepo "*" --enablerepo rhel-7-server-rpms \
              httpd php php-mysql php-gd openssl psmisc && \
            yum clean all

1. Add the dependent scripts and make them executable.

        ADD scripts /scripts
        RUN chmod 755 /scripts/*

1. Add the Wordpress source from gzip tar file. docker will extract the files. Also, modify permissions to support non-root container runtime. Switch to port 8080 for non-root apache runtime.

        COPY latest.tar.gz /latest.tar.gz
        RUN tar xvzf /latest.tar.gz -C /var/www/html --strip-components=1 && \
            rm /latest.tar.gz && \
            usermod -u 27 apache && \
            sed -i 's/^Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf && \
            APACHE_DIRS="/var/www/html /usr/share/httpd /var/log/httpd /run/httpd" && \
            chown -R apache:0 ${APACHE_DIRS} && \
            chmod -R g=u ${APACHE_DIRS}

1. Add an instruction to expose the web server port.

        EXPOSE 8080

1. Add a `VOLUME` instruction. This ensures data will be persisted even if the container is lost.

        VOLUME /var/www/html/wp-content/uploads /var/log/httpd /run/httpd

1. Switch to a non-root `USER`.

        USER apache

1. Finish by adding the `CMD` instruction.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the Dockerfile and exit the editor.

## Build Images, Test and Push

Now we are ready to build the images to test our Dockerfiles.

1. Build each image. When building an image docker requires the path to the directory of the Dockerfile.

        $ docker build -t mariadb mariadb/
        $ docker build -t wordpress wordpress/

1. If the build does not return `Successfully built <image_id>` then resolve the issue and build again. Once successful, list the images.

        $ docker images

1. Create the local directories for persistent storage & set permissions for container runtime.

        $ sudo mkdir -p /var/lib/mariadb /var/lib/wp_uploads
        $ sudo chown 27 /var/lib/mariadb /var/lib/wp_uploads

1. Run the database image to confirm connectivity. It takes some time to discover all of the necessary `docker run` options.

  * `-d` to run in daemonized mode
  * `-v <host/path>:<container/path>:Z` to bindmount the directory for persistent storage. The :Z option will label the content inside the container with the exact SELinux MCS label that the container runs. Below we'll inspect the labels on the directories before and after we run the container to see the changes on the labels in the directories
  * `-p <host_port>:<container_port>` to map the container port to the host port
```bash
$ ls -lZd /var/lib/mariadb
$ docker run -d -v /var/lib/mariadb:/var/lib/mysql:Z -p 3306:3306 -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb --name mariadb mariadb
```

Note: See the difference in SELinux context after running w/ a volume & :Z.
```bash
$ ls -lZd /var/lib/mariadb
$ docker exec $(docker ps -ql) ps aux
```

Check volume directory ownership inside the container
```bash
$ docker exec $(docker ps -ql) stat --format="%U" /var/lib/mysql
$ docker logs $(docker ps -ql)
$ docker ps
$ curl localhost:3306
```

  **Note**: the `curl` command does not return useful information but demonstrates
            a response on the port.

5. Test the Wordpress image to confirm connectivity. Additional run options:
  * `--link <name>:<alias>` to link to the database container
```bash
$ ls -lZd /var/lib/wp_uploads
$ docker run -d -v /var/lib/wp_uploads:/var/www/html/wp-content/uploads:Z -p 8080:8080 --link mariadb:db --name wordpress wordpress
```

Note: See the difference in SELinux context after running w/ a volume & :Z.
```bash
$ ls -lZd /var/lib/wp_uploads
$ docker exec $(docker ps -ql) ps aux
```

Check volume directory ownership inside the container
```bash
$ docker exec $(docker ps -ql) stat --format="%U" /var/www/html/wp-content/uploads
$ docker logs $(docker ps -ql)
$ docker ps
$ curl -L http://localhost:8080
```

You may also load the Wordpress application in a browser to test its full functionality @ `http://<YOUR AWS VM PUBLIC DNS NAME HERE>:8080`.

### Simplify running containers with the atomic CLI

When we have a working `docker run` recipe we want a way to communicate that to the end-user. The `atomic` tool is installed on both RHEL and Atomic hosts. It is useful in controlling the Atomic host as well as running containers. It is able to parse the `LABEL` instruction in a `Dockerfile`. The `LABEL run` instruction prescribes how the image is to be run. In addition to providing informative human-readable metadata, `LABEL`s may be used by the `atomic` CLI to run an image the way a developer designed it to run. This avoids having to copy+paste from README files. For more information on the `atomic` command, please see the [documentation here](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/cli_reference/atomic_commands).

1. Edit `wordpress/Dockerfile` and add the following instruction near the bottom of the file above the CMD line.

        LABEL run docker run -d -v /var/lib/wp_uploads:/var/www/html/wp-content/uploads:Z -p 8080:8080 --link=mariadb:db --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE

1. Rebuild the Wordpress image. The image cache will be used so only the changes will need to be built.

        $ docker build -t wordpress wordpress/

1. Re-run the Wordpress image using the `atomic` CLI. We don't need to use a complicated, error-prone `docker run` string. Test using the methods from the earlier step. In addition, we are going to launch the image using the `atomic` command. Before we can do that, we'll install it as noted below.

        $ docker stop wordpress
        $ docker rm wordpress
        $ sudo yum -y install atomic
        $ atomic run wordpress
        $ curl -L http://localhost:8080

### Push images to local registry

1. Once satisfied with the images tag them with the URI of the local lab local registry. The tag is what OpenShift uses to identify the particular image that we want to import from the registry.

        $ docker tag mariadb localhost:5000/mariadb
        $ docker tag wordpress localhost:5000/wordpress
        $ docker images

1. Push the images

        $ docker push localhost:5000/mariadb
        $ docker push localhost:5000/wordpress

## Clean Up

Stop the mariadb and wordpress containers.

```bash
$ docker ps
$ docker stop mariadb wordpress
```

After iterating through running docker images you will likely end up with many stopped containers. List them.

```bash
$ docker ps -a
```

This command is useful in freeing up disk space by removing all stopped containers.

```bash
$ docker rm $(docker ps -qa)
```

This command will result in a cosmetic error because it is trying to stop running containers like the registry and the OpenShift containers that are running. These errors can safely be ignored.

In the [next lab](../lab4/chapter4.md) we introduce container orchestration via OpenShift.
