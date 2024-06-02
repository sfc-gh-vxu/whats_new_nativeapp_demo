create application role if not exists app_public;
create application role if not exists app_endpoint_role;

-- create or replace schema core;
create or alter versioned schema core;

-- a universal backdoor to run things as app_admin.
-- YOU DO NOT WANT TO DO THIS IN PRODUCTION :-)
create or replace procedure core.run(STMT string)
returns string
language javascript
execute as owner
as $$
    try {
        var res = snowflake.execute({sqlText: STMT});
        res.next();
        return res.getColumnValue(1);
    } catch(err) {
        return "ERROR: " + err.message;
    }
$$;

grant usage on schema core to application role app_public;
grant usage on schema core to application role app_endpoint_role;
grant usage on procedure core.run(string) to application role app_public;
grant usage on procedure core.run(string) to application role app_endpoint_role;

create or replace procedure core.init()
returns string language sql execute as owner as $$
begin
    create schema if not exists upgrades;
    create table if not exists upgrades.version_history(version string, id int autoincrement order);
    grant all privileges on schema upgrades to application role app_public;
    grant select on table upgrades.version_history to application role app_public;

    insert into upgrades.version_history(version) values ('version 0');

    -- version initializer callback can be used to upgrade services:
    alter service if exists services.app_service from spec='spec.yml';
    return 'init complete';
end $$;

execute immediate from './callbacks.sql';
execute immediate from './services.sql';