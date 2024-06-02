-- namespace under which our services and their functions will live
create schema if not exists services;
grant usage on schema services to application role app_public;

-- creates a compute pool, service, and service function
create or replace procedure setup.create_services()
returns varchar
language sql
execute as owner
as $$
    begin
        CREATE COMPUTE POOL if not exists backend_compute_pool
            min_nodes = 1
            max_nodes = 1
            instance_family = CPU_X64_XS;

        CREATE SERVICE if not exists services.backend
            in compute pool backend_compute_pool
            from spec='backend.yaml';
        grant usage on service services.backend to application role app_public;
        
        CREATE COMPUTE POOL if not exists frontend_compute_pool
            min_nodes = 1
            max_nodes = 1
            instance_family = CPU_X64_XS;

        CREATE SERVICE if not exists services.frontend
            in compute pool frontend_compute_pool
            from spec='frontend.yaml'
            EXTERNAL_ACCESS_INTEGRATIONS=(REFERENCE('EAI_WIKI'));
        grant usage on service services.frontend to application role app_public;
        
        return 'Done';
    end;
$$;
grant usage on procedure setup.create_services() to application role app_public;

create or replace procedure setup.redeploy_services()
returns varchar
language sql
execute as owner
as $$
    begin
        alter service services.frontend from spec='frontend.yaml';
        alter service services.backend from spec='backend.yaml';
        return 'Done';
    end;
$$;
grant usage on procedure setup.redeploy_services() to application role app_public;


create or replace procedure setup.suspend_services()
returns varchar
language sql
execute as owner
as $$
    begin
        alter service services.frontend suspend;
        alter service services.backend suspend;
        return 'Done';
    end;
$$;
grant usage on procedure setup.suspend_services() to application role app_public;

create or replace procedure setup.resume_services()
returns varchar
language sql
execute as owner
as $$
    begin
        alter service services.backend resume;
        alter service services.frontend resume;
        return 'Done';
    end;
$$;
grant usage on procedure setup.resume_services() to application role app_public;

create or replace procedure setup.drop_services_and_pool()
returns varchar
language sql
execute as owner
as $$
    begin
        drop service if exists services.frontend;
        drop service if exists services.backend;
        drop compute pool if exists frontend_compute_pool;
        drop compute pool if exists backend_compute_pool;
        return 'Done';
    end;
$$;
grant usage on procedure setup.drop_services_and_pool() to application role app_public;

create or replace procedure setup.service_status()
returns varchar
language sql
execute as owner
as $$
    declare
        service_status varchar;
    begin
        call system$get_service_status('services.frontend') into :service_status;
        return parse_json(:service_status)[0]['status']::varchar;
    end;
$$;
grant usage on procedure setup.service_status() to application role app_public;