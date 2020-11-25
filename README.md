# tripalclone-docker

Creating a clone of an existing website in Docker for development and testing purposes.

## Usage

### In your existing site:

1. Go to [DrupalRoot]/sites/all and package the files there into a compressed tar named `alldir.tar.gz`.

```
cd $DRUPAL_ROOT/sites/all
tar zcvf $DRUPAL_ROOT/alldir.tar.gz *
```

2. Go to [DrupalRoot]/sites/default and package the files directory into a compressed tar named `filesdir.tar.gz`

```
cd $DRUPAL_ROOT/sites/default
tar zcvf $DRUPAL_ROOT/filesdir.tar.gz files
```

3. Backup your database for use in the clone. **This will be very slow depending on the size of your database**

```
cd $DRUPAL_ROOT
pg_dump --no-owner --no-privileges --format=c --compress=9 --user=[user] --dbname=[db] --file=database.pgdump
```

4. Move both tar files and the pgdump file created above from your Drupal Root to within this repository.

### In this repository

1. Triple check that there are 3 additional files in this repository specific to the clone you would like to make.

  - alldir.tar.gz containing the modules, libraries and themes
	- filesdir.tar.gz containing all the user files associated with your site
	- database.pgdump containing a compressed archive of your drupal and chado schema

	**NOTE: They must all be from the same time/version of your website.**

2. Build an image specific to your clone! **There must be no spaces in the tag!**

```
docker build --tag=[db]:[date] .
```

This will produce a docker image which you can spawn as many containers from as you like which represents this exact time in your production Tripal site!

### Create a free standing container for UI testing.

For this step it does not matter where you run the following run command as the container is fully free standing.

```
docker run --publish=9000:80 --name=tclone -tid  \
  -e DBPASS='somesecurepassword' \
  [tag from above]
docker exec -it tclone service postgresql restart
```

Next steps,
 - To interact with the container you go to http://localhost:9000 in your browser.
 - To open a shell inside the container `docker exec -it tclone bash`
 - To run a drush command `docker exec -it --wordir=/var/www/html/vendor/bin tclone drush cc all`
 - To restart the database `docker exec -it tclone service postgresql restart`

## Create a mounted container for module development/testing.

1. Clone the repository you would like to work on locally. I recommend doing this in a dockers directory so you can later find which directory you mounted ;-p

```
cd ~/Dockers
git clone https://github.com/tripal/tripal
cd tripal
```

2. Create a docker container mounted **within your cloned repository**.

```
docker run --publish=9000:80 --name=tclone -tid \
	--volume=`pwd`:var/www/sites/all/modules/tripal \
	-e DBPASS='somesecurepassword' \
	[tag from above]
docker exec -it tclone service postgresql restart
```

Next steps,
	- Any changes you make in your local directory will be automatically sync'd within your container.
	- To interact with the container you go to http://localhost:9000 in your browser.
  - To open a shell inside the container `docker exec -it tclone bash`
  - To run a drush command `docker exec -it --wordir=/var/www/html/vendor/bin tclone drush cc all`
  - To restart the database `docker exec -it tclone service postgresql restart`
