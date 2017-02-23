This library is setup using Docker and docker-compose, meaning you don't even need to have Ruby or any of the dependencies installed locally – you only need the [Docker Toolbox](https://www.docker.com/products/docker-toolbox).

Once you have the toolbox installed and running, you can boot a Pry console with the library loaded by simply running `./bin/console`. docker-compose will take care of downloading and installing dependencies.

For your common commands, you'll need to use the script equivalents in the `bin` folder, e.g. `./bin/bundle exec ...`, `./bin/rake -T` etc.

Tests can be run simply by using `./bin/rspec`.

If you need to run a custom command, you can use `./bin/run command here`, e.g. `./bin/run bash` will give you a bash console to the Docker instance.
