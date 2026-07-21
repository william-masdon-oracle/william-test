/*
  Proposed LiveLabs ORDS sync endpoint for WMS LiveStack events.

  Security note: before enabling this outside a trusted development environment,
  attach the wms/livestack-events/* URL pattern to the same ORDS privilege or
  OAuth protection model used by the existing WMS-to-LiveLabs sync endpoints.
*/

create or replace package ll_pkg_wms_livestack_events as
    /*
      Expected POST body:
      {
        "id": 123,
        "eventCode": "00123-ABCD-EFGH",
        "livestackId": 456,
        "activeFlag": "Y",
        "emailCreator": "user@oracle.com",
        "emailRequestor": "other@oracle.com",
        "validFrom": "2026-07-21T09:00:00",
        "validTo": "2026-07-25T17:00:00",
        "validTimezone": "America/Los_Angeles",
        "eventTitle": "LiveStack Event",
        "descLongOverride": "...",
        "outlineOverride": "...",
        "prereqsOverride": "...",
        "remarks": "...",
        "entries": [
          {
            "livestackEntryId": 1001,
            "voucherId": 2001,
            "activeFlag": "Y"
          }
        ]
      }
    */
    procedure upsert_from_json (
        p_payload     in clob,
        p_status_code out number,
        p_response    out clob
    );

    procedure get_as_json (
        p_livestack_event_id in number,
        p_status_code        out number,
        p_response           out clob
    );
end ll_pkg_wms_livestack_events;
/

create or replace package body ll_pkg_wms_livestack_events as
    function clean_flag (
        p_value   in varchar2,
        p_default in varchar2 default 'Y'
    ) return varchar2 is
    begin
        return case upper(nvl(trim(p_value), p_default))
            when 'Y' then 'Y'
            when 'N' then 'N'
            else p_default
        end;
    end clean_flag;

    function parse_json_date (
        p_value in varchar2
    ) return date is
    begin
        if trim(p_value) is null then
            return null;
        end if;

        begin
            return cast(to_timestamp_tz(p_value, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') as date);
        exception
            when others then
                null;
        end;

        begin
            return cast(to_timestamp_tz(p_value, 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM') as date);
        exception
            when others then
                null;
        end;

        begin
            return to_date(p_value, 'YYYY-MM-DD"T"HH24:MI:SS');
        exception
            when others then
                null;
        end;

        begin
            return to_date(p_value, 'YYYY-MM-DD HH24:MI:SS');
        exception
            when others then
                null;
        end;

        begin
            return to_date(p_value, 'MM/DD/YYYY HH:MI AM');
        exception
            when others then
                null;
        end;

        return to_date(p_value, 'MM/DD/YYYY');
    end parse_json_date;

    function response_json (
        p_status  in varchar2,
        p_message in varchar2,
        p_id      in number default null,
        p_code    in varchar2 default null
    ) return clob is
        l_response clob;
    begin
        select json_object(
                   'status' value p_status,
                   'message' value p_message,
                   'id' value p_id,
                   'eventCode' value p_code
                   returning clob
               )
          into l_response
          from dual;

        return l_response;
    end response_json;

    procedure upsert_from_json (
        p_payload     in clob,
        p_status_code out number,
        p_response    out clob
    ) is
        l_id                 ll_livestack_events.id%type;
        l_event_code         ll_livestack_events.event_code%type;
        l_livestack_id       ll_livestack_events.livestack_id%type;
        l_active_flg         ll_livestack_events.active_flg%type;
        l_email_creator      ll_livestack_events.email_creator%type;
        l_email_requestor    ll_livestack_events.email_requestor%type;
        l_valid_from         ll_livestack_events.valid_from%type;
        l_valid_to           ll_livestack_events.valid_to%type;
        l_valid_timezone     ll_livestack_events.valid_timezone%type;
        l_event_title        ll_livestack_events.event_title%type;
        l_desc_long_override ll_livestack_events.desc_long_override%type;
        l_outline_override   ll_livestack_events.outline_override%type;
        l_prereqs_override   ll_livestack_events.prereqs_override%type;
        l_remarks            ll_livestack_events.remarks%type;
        l_valid_json         number;
        l_invalid_entries    number;
        l_mismatched_entries number;
        l_entries_present    varchar2(5);
    begin
        select case
                 when p_payload is json then 1
                 else 0
               end
          into l_valid_json
          from dual;

        if l_valid_json = 0 then
            p_status_code := 400;
            p_response := response_json('error', 'Request body must be valid JSON.');
            return;
        end if;

        select json_value(p_payload, '$.id' returning number null on error),
               json_value(p_payload, '$.eventCode' returning varchar2(50) null on error),
               json_value(p_payload, '$.livestackId' returning number null on error),
               clean_flag(json_value(p_payload, '$.activeFlag' returning varchar2(1) null on error)),
               json_value(p_payload, '$.emailCreator' returning varchar2(200) null on error),
               json_value(p_payload, '$.emailRequestor' returning varchar2(4000) null on error),
               parse_json_date(json_value(p_payload, '$.validFrom' returning varchar2(100) null on error)),
               parse_json_date(json_value(p_payload, '$.validTo' returning varchar2(100) null on error)),
               json_value(p_payload, '$.validTimezone' returning varchar2(50) null on error),
               json_value(p_payload, '$.eventTitle' returning varchar2(1000) null on error),
               json_value(p_payload, '$.descLongOverride' returning varchar2(4000) null on error),
               json_value(p_payload, '$.outlineOverride' returning varchar2(4000) null on error),
               json_value(p_payload, '$.prereqsOverride' returning varchar2(4000) null on error),
               json_value(p_payload, '$.remarks' returning varchar2(4000) null on error)
          into l_id,
               l_event_code,
               l_livestack_id,
               l_active_flg,
               l_email_creator,
               l_email_requestor,
               l_valid_from,
               l_valid_to,
               l_valid_timezone,
               l_event_title,
               l_desc_long_override,
               l_outline_override,
               l_prereqs_override,
               l_remarks
          from dual;

        if l_id is null and l_event_code is not null then
            begin
                select id
                  into l_id
                  from ll_livestack_events
                 where event_code = l_event_code;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        if l_livestack_id is null then
            p_status_code := 400;
            p_response := response_json('error', 'livestackId is required.', l_id, l_event_code);
            return;
        end if;

        select case
                 when json_exists(p_payload, '$.entries') then 'true'
                 else 'false'
               end
          into l_entries_present
          from dual;

        select count(*)
          into l_invalid_entries
          from json_table(
                   p_payload,
                   '$.entries[*]'
                   columns (
                       livestack_entry_id number path '$.livestackEntryId',
                       voucher_id         number path '$.voucherId'
                   )
               )
         where livestack_entry_id is null
            or voucher_id is null;

        if l_invalid_entries > 0 then
            p_status_code := 400;
            p_response := response_json('error', 'Each entry requires livestackEntryId and voucherId.', l_id, l_event_code);
            return;
        end if;

        select count(*)
          into l_mismatched_entries
          from json_table(
                   p_payload,
                   '$.entries[*]'
                   columns (
                       livestack_entry_id number path '$.livestackEntryId',
                       voucher_id         number path '$.voucherId'
                   )
               ) jt
          left join ll_livestack_entries le
            on le.id = jt.livestack_entry_id
           and le.livestack_id = l_livestack_id
          left join ll_vouchers v
            on v.id = jt.voucher_id
           and v.workshop_id = le.entry_id
         where jt.livestack_entry_id is not null
           and jt.voucher_id is not null
           and (le.id is null or v.id is null);

        if l_mismatched_entries > 0 then
            p_status_code := 400;
            p_response := response_json(
                'error',
                'Each entry must belong to the LiveStack and reference a voucher for that entry workshop.',
                l_id,
                l_event_code
            );
            return;
        end if;

        update ll_livestack_events
           set event_code = coalesce(l_event_code, event_code),
               livestack_id = l_livestack_id,
               active_flg = l_active_flg,
               email_creator = l_email_creator,
               email_requestor = l_email_requestor,
               valid_from = l_valid_from,
               valid_to = l_valid_to,
               valid_timezone = l_valid_timezone,
               event_title = l_event_title,
               desc_long_override = l_desc_long_override,
               outline_override = l_outline_override,
               prereqs_override = l_prereqs_override,
               remarks = l_remarks
         where id = l_id;

        if sql%rowcount = 0 then
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
                event_title,
                desc_long_override,
                outline_override,
                prereqs_override,
                remarks
            ) values (
                l_id,
                l_event_code,
                l_livestack_id,
                l_active_flg,
                l_email_creator,
                l_email_requestor,
                l_valid_from,
                l_valid_to,
                l_valid_timezone,
                l_event_title,
                l_desc_long_override,
                l_outline_override,
                l_prereqs_override,
                l_remarks
            )
            returning id, event_code into l_id, l_event_code;
        else
            select event_code
              into l_event_code
              from ll_livestack_events
             where id = l_id;
        end if;

        if l_entries_present = 'true' then
            merge into ll_livestack_event_vouchers target
            using (
                select l_id as livestack_event_id,
                       jt.livestack_entry_id,
                       jt.voucher_id,
                       clean_flag(jt.active_flg) as active_flg
                  from json_table(
                           p_payload,
                           '$.entries[*]'
                           columns (
                               livestack_entry_id number path '$.livestackEntryId',
                               voucher_id         number path '$.voucherId',
                               active_flg         varchar2(1) path '$.activeFlag'
                           )
                       ) jt
                 where jt.livestack_entry_id is not null
                   and jt.voucher_id is not null
            ) source
               on (
                   target.livestack_event_id = source.livestack_event_id
                   and target.livestack_entry_id = source.livestack_entry_id
               )
             when matched then update
                  set target.voucher_id = source.voucher_id,
                      target.active_flg = source.active_flg
             when not matched then insert (
                  livestack_event_id,
                  livestack_entry_id,
                  voucher_id,
                  active_flg
             ) values (
                  source.livestack_event_id,
                  source.livestack_entry_id,
                  source.voucher_id,
                  source.active_flg
             );

            update ll_livestack_event_vouchers lev
               set active_flg = 'N'
             where lev.livestack_event_id = l_id
               and not exists (
                   select 1
                     from json_table(
                              p_payload,
                              '$.entries[*]'
                              columns (
                                  livestack_entry_id number path '$.livestackEntryId'
                              )
                          ) jt
                    where jt.livestack_entry_id = lev.livestack_entry_id
               );
        end if;

        commit;

        p_status_code := 200;
        p_response := response_json('success', 'LiveStack event synced.', l_id, l_event_code);
    exception
        when dup_val_on_index then
            rollback;
            p_status_code := 409;
            p_response := response_json('error', 'LiveStack event ID or event code already exists.', l_id, l_event_code);
        when others then
            rollback;
            p_status_code := 500;
            p_response := response_json('error', sqlerrm, l_id, l_event_code);
    end upsert_from_json;

    procedure get_as_json (
        p_livestack_event_id in number,
        p_status_code        out number,
        p_response           out clob
    ) is
    begin
        select json_object(
                   'id' value lse.id,
                   'eventCode' value lse.event_code,
                   'livestackId' value lse.livestack_id,
                   'activeFlag' value lse.active_flg,
                   'emailCreator' value lse.email_creator,
                   'emailRequestor' value lse.email_requestor,
                   'validFrom' value to_char(lse.valid_from, 'YYYY-MM-DD"T"HH24:MI:SS'),
                   'validTo' value to_char(lse.valid_to, 'YYYY-MM-DD"T"HH24:MI:SS'),
                   'validTimezone' value lse.valid_timezone,
                   'eventTitle' value lse.event_title,
                   'descLongOverride' value lse.desc_long_override,
                   'outlineOverride' value lse.outline_override,
                   'prereqsOverride' value lse.prereqs_override,
                   'remarks' value lse.remarks,
                   'entries' value (
                       select json_arrayagg(
                                  json_object(
                                      'livestackEntryId' value lev.livestack_entry_id,
                                      'voucherId' value lev.voucher_id,
                                      'voucherCode' value v.voucher_code,
                                      'activeFlag' value lev.active_flg
                                  )
                                  order by le.position nulls last, le.id
                                  returning clob
                              )
                         from ll_livestack_event_vouchers lev
                         join ll_livestack_entries le
                           on le.id = lev.livestack_entry_id
                         join ll_vouchers v
                           on v.id = lev.voucher_id
                        where lev.livestack_event_id = lse.id
                   ) format json
                   returning clob
               )
          into p_response
          from ll_livestack_events lse
         where lse.id = p_livestack_event_id;

        p_status_code := 200;
    exception
        when no_data_found then
            p_status_code := 404;
            p_response := response_json('error', 'LiveStack event not found.', p_livestack_event_id);
        when others then
            p_status_code := 500;
            p_response := response_json('error', sqlerrm, p_livestack_event_id);
    end get_as_json;
end ll_pkg_wms_livestack_events;
/

begin
    ords.define_module(
        p_module_name    => 'wms-livestack-events',
        p_base_path      => 'wms/livestack-events/',
        p_items_per_page => 0,
        p_status         => 'PUBLISHED',
        p_comments       => 'WMS sync endpoints for LiveStack events.'
    );

    ords.define_template(
        p_module_name => 'wms-livestack-events',
        p_pattern     => ''
    );

    ords.define_handler(
        p_module_name => 'wms-livestack-events',
        p_pattern     => '',
        p_method      => 'POST',
        p_source_type => ords.source_type_plsql,
        p_source      => q'[
declare
    l_status_code number;
    l_response    clob;
begin
    ll_pkg_wms_livestack_events.upsert_from_json(
        p_payload     => :body_text,
        p_status_code => l_status_code,
        p_response    => l_response
    );

    :status_code := l_status_code;
    owa_util.mime_header('application/json', false);
    htp.p('Cache-Control: no-store');
    owa_util.http_header_close;
    htp.prn(l_response);
end;
]',
        p_comments    => 'Insert or update a LiveStack event and its entry voucher mappings.'
    );

    ords.define_template(
        p_module_name => 'wms-livestack-events',
        p_pattern     => ':id'
    );

    ords.define_handler(
        p_module_name => 'wms-livestack-events',
        p_pattern     => ':id',
        p_method      => 'GET',
        p_source_type => ords.source_type_plsql,
        p_source      => q'[
declare
    l_status_code number;
    l_response    clob;
begin
    ll_pkg_wms_livestack_events.get_as_json(
        p_livestack_event_id => :id,
        p_status_code        => l_status_code,
        p_response           => l_response
    );

    :status_code := l_status_code;
    owa_util.mime_header('application/json', false);
    htp.p('Cache-Control: no-store');
    owa_util.http_header_close;
    htp.prn(l_response);
end;
]',
        p_comments    => 'Return a LiveStack event and its entry voucher mappings.'
    );

    commit;
end;
/
