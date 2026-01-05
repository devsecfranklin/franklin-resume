# Elasticsearch Configuration and Maintenance (pre 11.0)

This paper is meant to aid engineers in the field working with Palo
Alto Panorama and the integrated instances of Elasticsearch. These ES
processes running on Panorama are used to ingest and manage Next Gen
FireWall (NGFW) traffic logs. The Palo Alto Networks Firewalls (all types)
do not run the Elasticsearch daemons and therefore are not impacted
by Elasticsearch concerns.

Most ES issues we are seeing have been happening during software upgrades,
including full and point releases. There is some amount of desynchronization
between what is seen in the graphical interface of the Panorama and the "true"
status of the ES daemons as seen from the CLI.

## Check ES Health

A Panorama in a Log-Collector Group is restarted. Once the node in an Elasticsearch
cluster starts, it starts loading the shards. During this time, Elasticsearch
cluster health status is red and this can take 30 min to 6 hours before status
becomes green. The time taken is proportional to the amount of data on the box.

The Elasticsearch health status can be checked using this CLI command `show log-collector-es-cluster health`.

- [Health status of an Elasticsearch cluster in a Panorama Log-Collector Group
becomes red when one of the nodes is restarted.](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u0000004LhKCAU)

```sh
less mp-log ms.log # To review any generic issue
less mp-log # Review any log file starting with "es_"
less es-log # Review log files if there any any generated
```

## ES Log Recovery

We can use the following CLI command to re-ingest the missing ES data, where we can
specify the time range we want to re-ingest from the raw logs on disk back into
ES:

```sh
debug logdb migrate-lc start log-type all time period start-date <value> end-date <value>
```

Please note that this will have performance impacts to both ingestion and reporting/querying.
So expect reduced logging rate on the LC as well as potentially slower query and
report times while the migration is running. Depending on the amount of the logs, the
migration can take several days or more.

## LC Replication

### Disable LC Replication

Do not perform this step unless you are explicitly instructed to do so by Palo engineering team.

The purpose of this step is to avoid issues with Elasticsearch shard re-assignment during and after the upgrade. The premise behind this is the shards will not have to be replicated to each Panorama in TESTNET or PROD during and just after the upgrade, which will allow a more orderly recovery of the system post-upgrade.

### Enable LC Replication

Do not perform this step unless you are explicitly instructed to do so by Palo Alto Networks support/engineering team.

The purpose of this step is to avoid issues with Elasticsearch shard re-assignment during and after the upgrade. The premise behind this is the shards will not have to be replicated to each Panorama in TESTNET or PROD during and just after the upgrade, which will allow a more orderly recovery of the system post-upgrade.

## Master Not Discovered

If after upgrading and rebooting both peers and waiting 5-10 minutes you are still
seeing 'master_not_discovered' when running >show log-collector-es-cluster health
you can run this command on the peer which was rebooted first (usually secondary).

```sh
debug elasticsearch es-restart option ssh-tunnel
```

## Tips to Prepare for Panorama Upgrades

- Commit all changes to panorama.
- [Preform a backup of the current configuration.](https://docs.paloaltonetworks.com/panorama/10-2/panorama-admin/administer-panorama/manage-panorama-and-firewall-configuration-backups)
- [Ensure that the latest content updates are properly installed.](https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-upgrade/software-and-content-updates/install-content-and-software-updates)
- Review the currently installed Panorama plugins. Ensure that you will have the
  correct versions off all plugins running at the conclusion of the upgrades.

### Tips for Upgrade to 11.1

11.0 is a "skip release". While it does need to be downloaded to the Panorama being
upgraded, the release should no be installed. For example, to upgrade from 10.2.8-h3
to 11.1.4-h3, it is enough to have the 11.0.0 and 11.1.0 releases downloaded to the
Panorama, and installed 11.1.4-h3 directly.

It is important to note that Elasticsearch on PanOS needs new TCP ports opened to
continue to function correctly. This is a change from previos releases, and does not
happen automatically.

| --- | --- | --- |
| Datagram | Port | Notes |
| TCP | 28270 | |
| TCP | 9300 to 9302 |  11.1 and later. Used for communication among Log Collectors in a Collector Group for log distribution. |

## Known Issues

PAN-273026
