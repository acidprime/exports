# Simple PuppetDB wrapper
This is a puppet face that will display all exports in puppetdb from the command line

# Task Usage

## Requirements

This module is compatible with Puppet Enterprise and Puppet Bolt.

* To [run tasks with Puppet Enterprise](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html), PE 2017.3 or later must be used.

* To [run tasks with Puppet Bolt](https://puppet.com/docs/bolt/0.x/running_tasks_and_plans_with_bolt.html), Bolt 0.5 or later must be installed on the machine from which you are running task commands. The master receiving the task must have SSH enabled.

### Puppet Enterprise Tasks

With Puppet Enterprise 2017.3 or higher, you can run this task [from the console](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks_in_the_console.html) or the command line.

Here's a command line example where we are checking for the exported Host resources from the Puppet master, `master.corp.net`:

```shell
[abir@workstation]$ puppet task run exports resources=Host --nodes master.corp.net

Starting job ...
New job ID: 247
Nodes: 1

Started on master.corp.net ...
Finished on node master.corp.net
  STDOUT:
    Name                                 Exports
    master.corp.net                      Host[master.corp.net]

Job completed. 1/1 nodes succeeded.
Duration: 2 sec
```

### Bolt

With [Bolt](https://puppet.com/docs/bolt/0.x/running_tasks_and_plans_with_bolt.html), you can run this task on the command line like so:

```shell
bolt task run exports resources=Host --nodes master.corp.net
```

## Parameters

* `resources`: Filter the query to just a particular resource


# Module Usage
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
puppet node exports --resources user
```

```shell
Name                                 Exports
puppet3.puppetlabs.vm                User[foooo]
```
