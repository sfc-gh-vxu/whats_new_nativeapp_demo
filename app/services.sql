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
        CREATE COMPUTE POOL if not exists wndemoapp_cp
            min_nodes = 1
            max_nodes = 1
            instance_family = CPU_X64_XS;

        CREATE WAREHOUSE if not exists query_wh;

        CREATE SERVICE if not exists services.app_service
            in compute pool wndemoapp_cp
            from spec='spec.yml'
            EXTERNAL_ACCESS_INTEGRATIONS = (REFERENCE('EAI_WIKI')),
            QUERY_WAREHOUSE = query_wh;
        grant usage on service services.app_service to application role app_public;
        
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
        alter service services.app_service from spec='spec.yml';
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
        alter service services.app_service suspend;
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
        alter service services.app_service resume;
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
        drop service if exists services.app_service;
        drop compute pool if exists wndemoapp_cp;
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
        call system$get_service_status('services.app_service') into :service_status;
        return parse_json(:service_status)[0]['status']::varchar;
    end;
$$;
grant usage on procedure setup.service_status() to application role app_public;