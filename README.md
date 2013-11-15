# Simple PuppetDB wrapper
This is a puppet face that will display all exports in puppetdb from the command line

# Usage
1. Install the module into your modulepath

```shell
puppet node exports
```

An example use would be monitoring students checking into the puppet master in the puppet advanced class

```shell
while :; do clear; puppet node exports --highlight; sleep 2; done
```
or if you do not have `--color` in watch:
```shell
watch 'puppet node exports'
```

## Example Usage

To query for all exported resources ( be aware there is a 20,000 limit by default )
```shell
puppet node exports
```

```shell
Name                                 Exports
puppet3.puppetlabs.vm                File[/tmp/production_puppet3.puppetlabs.vm_2]
puppet3.puppetlabs.vm                File[/tmp/production_puppet3.puppetlabs.vm]
puppet3.puppetlabs.vm                User[foooo]
```
To query for just user resources
```shell
puppet node exports user
```

```shell
Name                                 Exports
puppet3.puppetlabs.vm                User[foooo]
```
