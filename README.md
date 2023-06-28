# automation
Collection of scripts to automate the daily work.

It is recommended to make a symlink to the scripts (without the .sh extension) in `/usr/bin`.

## eep.sh

This script automates the actions required to enter an epod. "Entering" meaning entering one of the following containers an epod is made of:
* the container of the key manager (`km`)
* the container of the Symphony backend (`sbe`)
* the container of Hbase (`hb`)
* the container of Mongo (`mg`)

For the key manager container the required environment variables are automatically set too, so the key manager and Wenger can be used right away, with no additional actions (specific additional actions may be needed for Wenger, depending on the invoked module though).

For the Hbase container, you can use command `hb` right away to drop to a Hbase shell once you entered the container.

Fot the Mongo container, you can use command `mg` right away to drop to a Mongo shell once you entered the container.

[This Jenkins job](https://warpdrive-lab.dev.symphony.com/jenkins/view/Security/job/security-pipeline-new) is used to start epods.

**Usage**

`$>eep`
to fetch all epods. It's convenient since it's not needed to open a web browser in order to check the list of epods on Jenkins. For the time being, all epods including dead ones are fetched, an improvement will come to fetch only live epods.

`$>eep <container> <identifier>`
where `<container>` is in {`km`, `sbe`, `hb`, `mg`}, see above ; and `<identifier>` is either the full Kubernetes namespace of your epod (this approach is recommended if you don't always keep a fixed prefix when you launch the Jenkins job for your epods), or just the build number of your epod (this approach is recommended if you always use the same prefix when you launch the Jenkins job for your epods). By "prefix", I mean the prefix used to create the Kubernetes namespace for your epod (variable `DEPLOYMENT_NAME` in the form of the Jenkins job).
If you use the second approach, then you need to set the environemnt variable `EPNS` to the (fixed) prefix.

Examples:
`$>eep km loic-1777`

`$>eep km 1777`




## eexp.sh

Similar to eep.sh but for a cross pod. It takes an additional argument to specify the targeted epod (1 or 2).
TODO: consider the possibility to fuse eep.sh and eexp.sh into a single script.


## pfep.sh
