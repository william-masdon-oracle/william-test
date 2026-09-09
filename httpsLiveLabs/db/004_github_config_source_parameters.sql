-- Create parameter names without putting credentials in source control.
--
-- Populate GITHUB_ACCESS_TOKEN through the protected LiveLabs system-parameter
-- administration path after this script is deployed. The token must have only
-- the repository permissions required to read the Terraform repository.

MERGE INTO ll_system_parameters target
USING (SELECT 'GITHUB_ACCESS_TOKEN' AS name FROM dual) source
ON (target.name = source.name)
WHEN NOT MATCHED THEN
  INSERT (name, value)
  VALUES (source.name, NULL);

MERGE INTO ll_system_parameters target
USING (SELECT 'GITHUB_API_ENDPOINT' AS name FROM dual) source
ON (target.name = source.name)
WHEN NOT MATCHED THEN
  INSERT (name, value)
  VALUES (source.name, 'https://github.com/oracle-livelabs/');

MERGE INTO ll_system_parameters target
USING (SELECT 'GITHUB_CSP_DISPLAY_NAME' AS name FROM dual) source
ON (target.name = source.name)
WHEN NOT MATCHED THEN
  INSERT (name, value)
  VALUES (source.name, 'GitHub Access for Terraform Files');

MERGE INTO ll_system_parameters target
USING (SELECT 'RECONCILE_HTTPS_IPS' AS name FROM dual) source
ON (target.name = source.name)
WHEN NOT MATCHED THEN
  INSERT (name, value)
  VALUES (source.name, 'N');

COMMIT;
