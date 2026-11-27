# ClamAV Buildpack

Deploy [ClamAV] on Scalingo using this buildpack.


## Documentation

See the official tutorial:
👉 https://doc.scalingo.com/tutorials/clamav


## Default Supported Version

The default ClamAV version deployed by this buildpack depends on your stack.
It is specified in the corresponding inventory file of the buildpack:
- For [`scalingo-26`][inventory-26]
- For [`scalingo-24`][inventory-24]
- For [`scalingo-22`][inventory-22]


## Maintenance Status

This buildpack is maintained by Scalingo solely for the deployment assets and
integration guidance provided in this repository and its associated
documentation.

Scalingo does not administer, manage, operate, or automatically upgrade
customer ClamAV instances.

Applying ClamAV upgrades and security patches remains the responsibility of
the customer by updating the `CLAMAV_VERSION` variable and redeploying the
application.

Should Scalingo discontinue maintenance of this buildpack or no longer
recommend its use, a notice period of at least six months will be provided
whenever feasible, except where immediate action is required due to security
concerns or external constraints.


[inventory-26]: INVENTORY-scalingo-26.tsv
[inventory-24]: INVENTORY-scalingo-24.tsv
[inventory-22]: INVENTORY-scalingo-22.tsv

[ClamAV]: https://www.clamav.net/
