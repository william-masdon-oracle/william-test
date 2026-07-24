
-- Proposed ORDS REST module for writing LiveStack event objects in LiveLabs.
-- Based on ORDS_REST_DBPM_livelabs.events.write_2026_07_21.sql.
-- Schema: DBPM  Date: Tue Jul 21 2026
--

DECLARE

  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;

BEGIN

  ORDS.DEFINE_MODULE(
      p_module_name    => 'livelabs.livestack_events.read',
      p_base_path      => '/livelabs/livestackEvents/read/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'livelabs.livestack_events.read',
      p_pattern        => 'getLiveStackEvent/:livestack_event_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'livelabs.livestack_events.read',
      p_pattern        => 'getLiveStackEvent/:livestack_event_id',
      p_method         => 'GET',
      p_source_type    => 'json/item',
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'select *
   from ll_livestack_events
  where id = :livestack_event_id');

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'livelabs.livestack_events.read',
      p_pattern        => 'getLiveStackEventEntries/:livestack_event_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'livelabs.livestack_events.read',
      p_pattern        => 'getLiveStackEventEntries/:livestack_event_id',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_mimes_allowed  => NULL,
      p_comments       => NULL,
      p_source         =>
'select lev.id,
        lev.livestack_event_id,
        lev.livestack_entry_id,
        lev.voucher_id,
        lev.active_flg,
        le.livestack_id,
        le.position,
        le.entry_type,
        le.entry_id as workshop_id,
        v.voucher_code as event_code
   from ll_livestack_event_vouchers lev
   join ll_livestack_entries le
     on le.id = lev.livestack_entry_id
   join ll_vouchers v
     on v.id = lev.voucher_id
  where lev.livestack_event_id = :livestack_event_id
  order by le.position nulls last, le.id');
  
  ORDS.DEFINE_MODULE(
      p_module_name    => 'livelabs.livestack_events.write',
      p_base_path      => '/livelabs/livestackEvents/write/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'createLiveStackEvent',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'createLiveStackEvent',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => 'application/json',
      p_comments       => NULL,
      p_source         =>
'begin
    insert into ll_livestack_events (
        id,
        event_code,
        livestack_id,
        active_flg,
        email_creator,
        email_requestor,
        valid_from,
        valid_to,
        valid_timezone,
        users_maximum,
        users_concurrent,
        event_title,
        desc_long_override,
        outline_override,
        prereqs_override,
        remarks
    ) values (
        :livestack_event_id,
        :event_code,
        :livestack_id,
        nvl(:active_flg, ''Y''),
        :email_creator,
        :email_requestor,
        to_date(:valid_from, ''MM/DD/YYYY''),
        to_date(:valid_to, ''MM/DD/YYYY''),
        :valid_timezone,
        :users_maximum,
        :users_concurrent,
        :event_title,
        :desc_long_override,
        :outline_override,
        :prereqs_override,
        :remarks
    )
    returning id, event_code into :return_id, :return_event_code;

    :status := 200;
exception
    when others then
        :status := 500;
        :error_message := sqlerrm;
end;');

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'createLiveStackEvent',
      p_method             => 'POST',
      p_name               => 'Error_Message',
      p_bind_variable_name => 'error_message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'createLiveStackEvent',
      p_method             => 'POST',
      p_name               => 'LiveStack_Event_Code',
      p_bind_variable_name => 'return_event_code',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'createLiveStackEvent',
      p_method             => 'POST',
      p_name               => 'LiveStack_Event_ID',
      p_bind_variable_name => 'return_id',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'createLiveStackEvent',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'updateLiveStackEvent/:livestack_event_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'updateLiveStackEvent/:livestack_event_id',
      p_method         => 'PUT',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => 'application/json',
      p_comments       => NULL,
      p_source         =>
'begin
    update ll_livestack_events
       set event_code = coalesce(:event_code, event_code),
           livestack_id = :livestack_id,
           active_flg = nvl(:active_flg, ''Y''),
           email_creator = :email_creator,
           email_requestor = :email_requestor,
           valid_from = to_date(:valid_from, ''MM/DD/YYYY''),
           valid_to = to_date(:valid_to, ''MM/DD/YYYY''),
           valid_timezone = :valid_timezone,
           users_maximum = :users_maximum,
           users_concurrent = :users_concurrent,
           event_title = :event_title,
           desc_long_override = :desc_long_override,
           outline_override = :outline_override,
           prereqs_override = :prereqs_override,
           remarks = :remarks
     where id = :livestack_event_id;

    if sql%rowcount = 0 then
        :status := 404;
        :error_message := ''LiveStack event not found.'';
    else
        :status := 200;
    end if;
exception
    when others then
        :status := 400;
        :error_message := sqlerrm;
end;');

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'updateLiveStackEvent/:livestack_event_id',
      p_method             => 'PUT',
      p_name               => 'Error_Message',
      p_bind_variable_name => 'error_message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'updateLiveStackEvent/:livestack_event_id',
      p_method             => 'PUT',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'syncLiveStackEventEntries/:livestack_event_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'livelabs.livestack_events.write',
      p_pattern        => 'syncLiveStackEventEntries/:livestack_event_id',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_mimes_allowed  => 'application/json',
      p_comments       => NULL,
      p_source         =>
'declare
    l_payload        clob := :body_text;
    l_parent_exists  number;
    l_invalid_count  number;
    l_duplicate_count number;
    l_invalid_flag_count number;
begin
    select count(*)
      into l_parent_exists
      from ll_livestack_events
     where id = :livestack_event_id;

    if l_parent_exists = 0 then
        :status := 404;
        :error_message := ''LiveStack event not found.'';
        return;
    end if;

    select count(*)
      into l_duplicate_count
      from (
          select jt.livestack_entry_id
            from json_table(
                     l_payload,
                     ''$.entries[*]''
                     columns (
                         livestack_entry_id number path ''$.livestack_entry_id''
                     )
                 ) jt
           group by jt.livestack_entry_id
          having count(*) > 1
      );

    if l_duplicate_count > 0 then
        :status := 400;
        :error_message := ''Payload contains duplicate LiveStack entry mappings.'';
        return;
    end if;

    select count(*)
      into l_invalid_count
      from json_table(
               l_payload,
               ''$.entries[*]''
               columns (
                   livestack_entry_id number path ''$.livestack_entry_id'',
                   voucher_id         number path ''$.voucher_id''
               )
           ) jt
      left join ll_livestack_events lse
        on lse.id = :livestack_event_id
      left join ll_livestack_entries le
        on le.id = jt.livestack_entry_id
       and le.livestack_id = lse.livestack_id
      left join ll_vouchers v
        on v.id = jt.voucher_id
       and v.workshop_id = le.entry_id
     where jt.livestack_entry_id is null
        or jt.voucher_id is null
        or le.id is null
        or v.id is null;

    if l_invalid_count > 0 then
        :status := 400;
        :error_message := ''One or more submitted mappings reference an invalid LiveStack entry or voucher. Unselected entries should be omitted from the payload.'';
        return;
    end if;

    select count(*)
      into l_invalid_flag_count
      from json_table(
               l_payload,
               ''$.entries[*]''
               columns (
                   active_flg varchar2(1) path ''$.active_flg''
               )
           ) jt
     where jt.active_flg is not null
       and jt.active_flg not in (''Y'', ''N'');

    if l_invalid_flag_count > 0 then
        :status := 400;
        :error_message := ''active_flg must be Y or N.'';
        return;
    end if;

    delete from ll_livestack_event_vouchers lev
     where lev.livestack_event_id = :livestack_event_id
       and not exists (
           select 1
             from json_table(
                      l_payload,
                      ''$.entries[*]''
                      columns (
                          livestack_event_entry_id number path ''$.livestack_event_entry_id''
                      )
                  ) jt
            where jt.livestack_event_entry_id = lev.id
       );

    merge into ll_livestack_event_vouchers target
    using (
        select jt.livestack_event_entry_id,
               :livestack_event_id as livestack_event_id,
               jt.livestack_entry_id,
               jt.voucher_id,
               nvl(jt.active_flg, ''Y'') as active_flg
          from json_table(
                   l_payload,
                   ''$.entries[*]''
                   columns (
                       livestack_event_entry_id number path ''$.livestack_event_entry_id'',
                       livestack_entry_id       number path ''$.livestack_entry_id'',
                       voucher_id               number path ''$.voucher_id'',
                       active_flg               varchar2(1) path ''$.active_flg''
                   )
               ) jt
    ) source
       on (
           target.id = source.livestack_event_entry_id
           and target.livestack_event_id = source.livestack_event_id
       )
     when matched then update
          set target.livestack_entry_id = source.livestack_entry_id,
              target.voucher_id = source.voucher_id,
              target.active_flg = source.active_flg
     when not matched then insert (
          id,
          livestack_event_id,
          livestack_entry_id,
          voucher_id,
          active_flg
     ) values (
          source.livestack_event_entry_id,
          source.livestack_event_id,
          source.livestack_entry_id,
          source.voucher_id,
          source.active_flg
     );

    :status := 200;
exception
    when others then
        :status := 500;
        :error_message := sqlerrm;
end;');

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'syncLiveStackEventEntries/:livestack_event_id',
      p_method             => 'POST',
      p_name               => 'Error_Message',
      p_bind_variable_name => 'error_message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'livelabs.livestack_events.write',
      p_pattern            => 'syncLiveStackEventEntries/:livestack_event_id',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);

  l_modules(1) := 'livelabs.admin';
  l_modules(2) := 'livelabs.analytics';
  l_modules(3) := 'livelabs.computeImages';
  l_modules(4) := 'livelabs.events.read';
  l_modules(5) := 'livelabs.events.write';
  l_modules(6) := 'livelabs.greenbutton';
  l_modules(7) := 'livelabs.images';
  l_modules(8) := 'livelabs.policies';
  l_modules(9) := 'livelabs.tags.read';
  l_modules(10) := 'livelabs.tags.write';
  l_modules(11) := 'livelabs.tenancies.read';
  l_modules(12) := 'livelabs.terraformScripts';
  l_modules(13) := 'livelabs.workshops.read';
  l_modules(14) := 'livelabs.workshops.write';
  l_modules(15) := 'livelabs.livestack_events.read';
  l_modules(16) := 'livelabs.livestack_events.write';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'livelabs.admin.privileges',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'LiveLabs Admin Privileges',
      p_description    => 'LiveLabs Admin REST privileges for livelabs module',
      p_comments       => NULL);

  l_roles.DELETE;
  l_modules.DELETE;
  l_patterns.DELETE;

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;

END;
/
