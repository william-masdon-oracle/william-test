# HTTPS reserved public IP pool

Deploy the files in this order:

1. `001_https_reserved_public_ip_pool.sql`
2. `004_github_config_source_parameters.sql`
3. The updated `LL_PKG_CREATE`, `LL_PKG_DELETE`, and `LL_PKG_TERRAFORM`
   definitions in `../existingDDL/LLDEV_2026_09_03_063048_LLDEV_2026_09_03_063048_05_PACKAGES.sql`
4. `003_seed_reserved_public_ips.sql`
5. The three updated admin APEX page exports, including page 9253, **Reserved Public IPs**.

For LL Dev or another environment where `LL_RESERVED_PUBLIC_IPS` already
exists, run `dev/001_add_last_reservation_id.sql` before deploying the updated
packages and page export. Do not rerun the base table-creation script.

`003_seed_reserved_public_ips.sql` is the reviewed static seed generated from
the workbook. Run it after `001` and before enabling any script.

`LL_TF_SCRIPTS.HTTPS_ENABLED_FLG` defaults to `N`. Set it to `Y` only for a Terraform script that accepts these variables:

- `llIpAddress`
- `llDnsEntry`
- `llIpOcid`
- `llCertOcid`
- `llCertCAOcid`

Pool rows must be associated with LiveLabs `TENANCY_ID` and `REGION_ID`. A row may be activated only when both the Certificate and CA Bundle OCIDs are populated. The included workbook is the 1,500-row inventory source; every row in this revision contains both TLS OCIDs and is seeded active.

Allocation is least-recently-used within the reservation's tenancy/region and uses `FOR UPDATE SKIP LOCKED`, so concurrent reservations cannot claim the same endpoint. The unique `RESERVATION_ID` constraint also enforces one endpoint per reservation.

Before an endpoint is released, LiveLabs calls OCI `GET /20160918/publicIps/{ipOcid}` in the row's tenancy and region. Only an OCI result with `lifecycleState = AVAILABLE` and no `assignedEntityId` clears the assignment. The daily scheduled job repeats that check for any in-use pool row, recovering capacity after delayed OCI cleanup while never releasing an IP that OCI still reports as assigned.

`004_github_config_source_parameters.sql` creates parameter names only. Set
`GITHUB_ACCESS_TOKEN` through the protected system-parameter administration
path; do not add a token to any SQL file or APEX export. The OCI
`GITHUB_ACCESS_TOKEN` configuration-source-provider API uses a token and does
not accept a GitHub username, so there is no username credential to store for
that call.
