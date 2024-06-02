-- namespace for service administration
create or alter versioned schema setup;
grant usage on schema setup to application role app_public;

create or replace procedure setup.grant_callback(privileges array)
returns string
language javascript
execute as owner
as $$
    try {
      var res = snowflake.execute({sqlText: "CALL setup.create_services()"});
      res.next();
      return res.getColumnValue(1);
    } catch(err) {
      return "ERROR: " + err.message;
    }
$$;
grant usage on procedure setup.grant_callback(array) to application role app_public;

create or replace procedure setup.register_reference(ref_name string, operation string, ref_or_alias string)
returns string
as $$
begin
    case (:operation)
        when 'ADD' then
            select system$set_reference(:ref_name, :ref_or_alias);
        when 'REMOVE' then
            select system$remove_reference(:ref_name);
        when 'CLEAR' then
            select system$remove_reference(:ref_name);
        else
            return 'Unknown operation: ' || :operation;
    end case;
    return 'Completed';
end;
$$;
grant usage on procedure setup.register_reference(string, string, string) to application role app_public;

create or replace procedure setup.configuration_callback(ref_name string)
   returns string
   language sql
   as $$
      begin
        case (ref_name)
            when 'EAI_WIKI' then
                return '{\"type\": \"CONFIGURATION\", \"payload\":{\"host_ports\":[\"upload.wikimedia.org\"],
                    \"allowed_secrets\" : \"ALL\"}}';
        end case;
        return 'Completed';
      end;
   $$;
grant usage on procedure setup.configuration_callback(string) to application role app_public;