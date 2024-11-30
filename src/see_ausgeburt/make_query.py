from pan_cortex_data_lake import Credentials, QueryService


c = Credentials()
qs = QueryService(credentials=c)

SQL = "SELECT source_ip, dest_ip from `<tenant_id>.firewall.traffic` LIMIT 5"
q = qs.create_query(query_params={"query": SQL})
job_id = q.json()["jobId"]

for p in qs.iter_job_results(job_id=job_id):
    print(p.text)
