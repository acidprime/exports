# Simple PuppetDB wrapper
This is a puppet face that will display all exports in puppetdb from the command line

# Usage
1. Install the module into your modulepath
2. Currently reads puppet.conf and uses `server` to connect to via http pool

```shell
puppet node exports
```

An example use would be monitoring students checking into the puppet master in the puppet advanced class

```shell
while :; do clear; puppet node exports; sleep 2; done
```
or if you have a newer version of watch
```shell
watch  --color 'puppet node exports'
```

## Example output
```shell
Name                                 Exports
puppet3.puppetlabs.vm                File[/tmp/production_puppet3.puppetlabs.vm_2]
puppet3.puppetlabs.vm                File[/tmp/production_puppet3.puppetlabs.vm]
```
