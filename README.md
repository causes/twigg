[![Gem Version](https://badge.fury.io/rb/twigg.png)](http://badge.fury.io/rb/twigg)

# Twigg

Twigg collects statistics for a set of Git repositories. It assumes that all the
repositories are in one directory and up-to-date.

## Commands

### `twigg stats` (command-line tool)

Shows how many commits each person has made in a given timespan and in what
repositories.

Usage:

    twigg stats [--verbose|-v] <repos dir> <number of days>

### `twigg app` (web app)

The web app shows the same information as `twigg stats`. To run it, configure
`~/.twiggrc` to specify the `repositories_directory` containing all the
repositories you want to analyze (`twigg init` can be used to produce the
`~/.twiggrc` file) and ensure the twigg-app gem is installed (`gem install
twigg-app`).

Usage:

    twigg app # assumes `~/.twiggrc` at default location
    TWIGGRC=config.yml twigg app # custom location for configuration file
    twigg app --daemon --pidfile ~/twigg.pid # run as a daemon, with pidfile

### `twigg gerrit`

This subcommand clones a set of projects from a Gerrit instance, updates an
existing set of clones, or shows stats.

    twigg gerrit [--verbose|-v] clone
    twigg gerrit [--verbose|-v] update
    twigg gerrit [--verbose|-v] stats

In order to use the `gerrit` subcommand the twigg-gerrit gem must be installed
(`gem install twigg-gerrit`). The `gerrit stats` command additionally requires a
database adapter such as the "mysql2" gem, and a Gerrit instance with an
accessible database.

### `twigg git`

This subcommand can be used to run Git operations across a set of repositories.

    twigg git [--verbose|-v] gc

### `twigg github`

This subcommand clones a set of projects from a GitHub, or updates an existing
set of clones.

    twigg github [--verbose|-v] clone
    twigg github [--verbose|-v] update

### `twigg init`

Emits a sample `.twiggrc` configuration file to standard out, which you can
redirect into a file; for example, to place the sample file at `~/.twiggrc`:

    twigg init > ~/.twiggrc

### `twigg pivotal`

This subcommand, available when the twigg-pivotal gem is installed (via `gem
install twigg-pivotal`), shows an overview of open stories in a Pivotal Tracker
instance.

    twigg pivotal stats

### Options common to all commands

All Twigg commands can take a `--verbose` or `-v` flag to increase their
verbosity, or a `--debug` or `-d` flag to show debugging information in the
event of an error.

All Twigg commands will attempt to read configuration from `~/.twiggrc`, if
present. The path to the configuration file can also be set via the `TWIGGRC`
variable in the environment.

## Development

Use Bundler when manually running or testing `twigg` subcommands from a local
clone of the Twigg Git repo:

    cd $(git rev-parse --show-cdup)/twigg
    bundle exec bin/twigg stats <repos dir> <number of days>
    bundle exec bin/twigg app
    TWIGGRC=custom bundle exec bin/twigg app # custom config location

To interact with Twigg in a REPL:

    cd $(git rev-parse --show-cdup)/twigg
    TWIGGRC=custom bundle exec irb -r twigg

## Why "Twigg"

According to Merriam-Webster:

> twig (transitive verb)<br>
> <br>
> 1. notice, observe<br>
> 2. to understand the meaning of : comprehend

Originally, the gem was to be called "twig", but there is a pre-existing project
with that name, so we chose "twigg".

## Requirements

Twigg requires Ruby 2.0 or above.
