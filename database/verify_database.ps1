param(
  [string]$DatabaseName = "chatgptnutrition_verify",
  [string]$HostName = "localhost",
  [string]$UserName = "postgres",
  [string]$Password = "postgres"
)

$ErrorActionPreference = "Stop"

$psql = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psql) {
  $candidate = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
  if (Test-Path $candidate) {
    $psqlPath = $candidate
  } else {
    throw "psql was not found in PATH or at $candidate"
  }
} else {
  $psqlPath = $psql.Source
}

$dropdb = Join-Path (Split-Path $psqlPath) "dropdb.exe"
$createdb = Join-Path (Split-Path $psqlPath) "createdb.exe"
$env:PGPASSWORD = $Password

& $dropdb -h $HostName -U $UserName --if-exists $DatabaseName
& $createdb -h $HostName -U $UserName $DatabaseName
& $psqlPath -h $HostName -U $UserName -d $DatabaseName -v ON_ERROR_STOP=1 -f "database\schema.sql"
& $psqlPath -h $HostName -U $UserName -d $DatabaseName -v ON_ERROR_STOP=1 -f "database\seed.sql"
& $psqlPath -h $HostName -U $UserName -d $DatabaseName -v ON_ERROR_STOP=1 -f "database\migrations\001_literature_pipeline.sql"

& $psqlPath -h $HostName -U $UserName -d $DatabaseName -c @"
select 'ingredients' as table_name, count(*) from ingredients
union all select 'health_targets', count(*) from health_targets
union all select 'evidence_claims', count(*) from evidence_claims
union all select 'literature_import_results', count(*) from literature_import_results
union all select 'literature_extractions', count(*) from literature_extractions
union all select 'coupons', count(*) from coupons
order by table_name;
"@
