create or replace package wms_livestack_event_pkg as
    procedure remap_livestack_event (
        p_livestack_event_id in wms_livestack_events.id%type,
        p_new_livestack_id   in wms_livestack_events.livestack_id%type,
        p_event_title        in wms_livestack_events.event_title%type,
        p_email_creator      in wms_livestack_events.email_creator%type,
        p_email_requestor    in wms_livestack_events.email_requestor%type,
        p_valid_from         in wms_livestack_events.valid_from%type,
        p_valid_to           in wms_livestack_events.valid_to%type,
        p_valid_timezone     in wms_livestack_events.valid_timezone%type,
        p_event_status       in wms_livestack_events.event_status%type,
        p_updated_by         in varchar2
    );
end wms_livestack_event_pkg;
/

create or replace package body wms_livestack_event_pkg as
    procedure remap_livestack_event (
        p_livestack_event_id in wms_livestack_events.id%type,
        p_new_livestack_id   in wms_livestack_events.livestack_id%type,
        p_event_title        in wms_livestack_events.event_title%type,
        p_email_creator      in wms_livestack_events.email_creator%type,
        p_email_requestor    in wms_livestack_events.email_requestor%type,
        p_valid_from         in wms_livestack_events.valid_from%type,
        p_valid_to           in wms_livestack_events.valid_to%type,
        p_valid_timezone     in wms_livestack_events.valid_timezone%type,
        p_event_status       in wms_livestack_events.event_status%type,
        p_updated_by         in varchar2
    ) is
        l_old_livestack_id wms_livestack_events.livestack_id%type;
        l_map_id           wms_livestack_event_entries.id%type;
        l_event_id         wms_events.id%type;

        type t_event_ids is table of wms_events.id%type;
        l_delete_event_ids t_event_ids := t_event_ids();

        procedure clear_reuse_target is
        begin
            l_map_id := null;
            l_event_id := null;
        end clear_reuse_target;

        procedure update_event_for_entry (
            p_event_id        in wms_events.id%type,
            p_entry           in number,
            p_alwaysfree_flg  in varchar2,
            p_alwaysfree_url  in varchar2,
            p_freetier_flg    in varchar2,
            p_freetier_url    in varchar2,
            p_paid_flg        in varchar2,
            p_paid_url        in varchar2,
            p_greenbutton_flg in varchar2,
            p_greenbutton_url in varchar2,
            p_livesql_flg     in varchar2,
            p_livesql_url     in varchar2
        ) is
        begin
            update wms_events
               set title = p_event_title,
                   email_creator = p_email_creator,
                   email_requestor = p_email_requestor,
                   valid_from = p_valid_from,
                   valid_to = p_valid_to,
                   livelabs_id = p_entry,
                   active_flg = 'Y',
                   valid_timezone = p_valid_timezone,
                   alt_url = json_object(
                       'FREETIER_URL' value p_freetier_url,
                       'LIVELABS_URL' value p_greenbutton_url,
                       'ALWAYSFREE_URL' value p_alwaysfree_url,
                       'PAID_URL' value p_paid_url,
                       'LIVESQL_URL' value p_livesql_url,
                       'DESKTOP_GUIDE_URL' value null,
                       'DESKTOP_APP1_URL' value null,
                       'DESKTOP_APP2_URL' value null
                   ),
                   event_json = json_object(
                       'DisplayOciInstructions' value null,
                       'AlwaysFreeEnabled' value p_alwaysfree_flg,
                       'FreeTierEnabled' value p_freetier_flg,
                       'PaidTenancyEnabled' value p_paid_flg,
                       'LiveLabsGreenEnabled' value p_greenbutton_flg,
                       'LiveSQLEnabled' value p_livesql_flg,
                       'EventType' value null,
                       'EventDate' value null,
                       'EventLocation' value null,
                       'EventOrganizer' value null,
                       'EventIconLink' value null,
                       'YoutubeLink' value null,
                       'EventTcValue' value null,
                       'AdvertEnabled' value 'N'
                   ),
                   event_status = p_event_status,
                   updated_flg = case
                       when nvl(updated_flg, 0) = 2 then 2
                       else 1
                   end
             where id = p_event_id;
        end update_event_for_entry;
    begin
        if p_livestack_event_id is null or p_new_livestack_id is null then
            return;
        end if;

        begin
            select livestack_id
              into l_old_livestack_id
              from wms_livestack_events
             where id = p_livestack_event_id;
        exception
            when no_data_found then
                return;
        end;

        if l_old_livestack_id = p_new_livestack_id then
            return;
        end if;

        execute immediate 'set constraint wms_lse_entries_event_fk deferred';

        update wms_livestack_events
           set livestack_id = p_new_livestack_id,
               updated_flg = case
                   when nvl(updated_flg, 0) = 2 then 2
                   else 1
               end,
               updated_by = p_updated_by,
               updated_on = sysdate
         where id = p_livestack_event_id;

        for entry in (
            select le.id as livestack_entry_id,
                   le.entry_id as livelabs_id,
                   ll.alwaysfree_flg,
                   ll.alwaysfree_url,
                   ll.freetier_flg,
                   ll.freetier_url,
                   ll.paid_flg,
                   ll.paid_url,
                   ll.greenbutton_flg,
                   ll.greenbutton_url,
                   ll.livesql_flg,
                   ll.livesql_url
              from wms_livestack_entries le
              join workshop_ll ll
                on ll.id = le.entry_id
             where le.livestack_id = p_new_livestack_id
               and nvl(le.active_flg, 1) = 1
             order by le.position nulls last, le.id
        )
        loop
            clear_reuse_target;

            begin
                select lee.id, lee.event_id
                  into l_map_id, l_event_id
                  from wms_livestack_event_entries lee
                 where lee.livestack_event_id = p_livestack_event_id
                   and lee.livestack_entry_id = entry.livestack_entry_id
                 fetch first 1 row only;
            exception
                when no_data_found then
                    null;
            end;

            if l_map_id is null then
                begin
                    select lee.id, lee.event_id
                      into l_map_id, l_event_id
                      from wms_livestack_event_entries lee
                      join wms_livestack_entries old_le
                        on old_le.id = lee.livestack_entry_id
                     where lee.livestack_event_id = p_livestack_event_id
                       and old_le.livestack_id = l_old_livestack_id
                       and old_le.entry_id = entry.livelabs_id
                       and not exists (
                           select 1
                             from wms_livestack_event_entries existing_lee
                            where existing_lee.livestack_event_id = p_livestack_event_id
                              and existing_lee.livestack_entry_id = entry.livestack_entry_id
                       )
                     order by lee.id
                     fetch first 1 row only;
                exception
                    when no_data_found then
                        null;
                end;
            end if;

            if l_map_id is null then
                begin
                    select lee.id, lee.event_id
                      into l_map_id, l_event_id
                      from wms_livestack_event_entries lee
                     where lee.livestack_event_id = p_livestack_event_id
                       and not exists (
                           select 1
                             from wms_livestack_entries current_le
                            where current_le.id = lee.livestack_entry_id
                              and current_le.livestack_id = p_new_livestack_id
                              and nvl(current_le.active_flg, 1) = 1
                       )
                     order by lee.id
                     fetch first 1 row only;
                exception
                    when no_data_found then
                        null;
                end;
            end if;

            if l_map_id is null then
                insert into wms_events (
                    title,
                    email_creator,
                    email_requestor,
                    valid_from,
                    valid_to,
                    livelabs_id,
                    active_flg,
                    valid_timezone,
                    alt_url,
                    event_json,
                    event_status,
                    updated_flg,
                    livestack_event_id
                ) values (
                    p_event_title,
                    p_email_creator,
                    p_email_requestor,
                    p_valid_from,
                    p_valid_to,
                    entry.livelabs_id,
                    'Y',
                    p_valid_timezone,
                    json_object(
                        'FREETIER_URL' value entry.freetier_url,
                        'LIVELABS_URL' value entry.greenbutton_url,
                        'ALWAYSFREE_URL' value entry.alwaysfree_url,
                        'PAID_URL' value entry.paid_url,
                        'LIVESQL_URL' value entry.livesql_url,
                        'DESKTOP_GUIDE_URL' value null,
                        'DESKTOP_APP1_URL' value null,
                        'DESKTOP_APP2_URL' value null
                    ),
                    json_object(
                        'DisplayOciInstructions' value null,
                        'AlwaysFreeEnabled' value entry.alwaysfree_flg,
                        'FreeTierEnabled' value entry.freetier_flg,
                        'PaidTenancyEnabled' value entry.paid_flg,
                        'LiveLabsGreenEnabled' value entry.greenbutton_flg,
                        'LiveSQLEnabled' value entry.livesql_flg,
                        'EventType' value null,
                        'EventDate' value null,
                        'EventLocation' value null,
                        'EventOrganizer' value null,
                        'EventIconLink' value null,
                        'YoutubeLink' value null,
                        'EventTcValue' value null,
                        'AdvertEnabled' value 'N'
                    ),
                    p_event_status,
                    2,
                    p_livestack_event_id
                )
                returning id into l_event_id;

                insert into wms_livestack_event_entries (
                    livestack_event_id,
                    livestack_id,
                    livestack_entry_id,
                    event_id,
                    active_flg,
                    created_by
                ) values (
                    p_livestack_event_id,
                    p_new_livestack_id,
                    entry.livestack_entry_id,
                    l_event_id,
                    'Y',
                    p_updated_by
                );
            else
                update wms_livestack_event_entries
                   set livestack_id = p_new_livestack_id,
                       livestack_entry_id = entry.livestack_entry_id,
                       active_flg = 'Y',
                       updated_by = p_updated_by,
                       updated_on = sysdate
                 where id = l_map_id;

                update_event_for_entry(
                    p_event_id => l_event_id,
                    p_entry => entry.livelabs_id,
                    p_alwaysfree_flg => entry.alwaysfree_flg,
                    p_alwaysfree_url => entry.alwaysfree_url,
                    p_freetier_flg => entry.freetier_flg,
                    p_freetier_url => entry.freetier_url,
                    p_paid_flg => entry.paid_flg,
                    p_paid_url => entry.paid_url,
                    p_greenbutton_flg => entry.greenbutton_flg,
                    p_greenbutton_url => entry.greenbutton_url,
                    p_livesql_flg => entry.livesql_flg,
                    p_livesql_url => entry.livesql_url
                );
            end if;
        end loop;

        delete from wms_livestack_event_entries lee
         where lee.livestack_event_id = p_livestack_event_id
           and not exists (
               select 1
                 from wms_livestack_entries current_le
                where current_le.id = lee.livestack_entry_id
                  and current_le.livestack_id = p_new_livestack_id
                  and nvl(current_le.active_flg, 1) = 1
           )
        returning event_id bulk collect into l_delete_event_ids;

        if l_delete_event_ids.count > 0 then
            forall i in 1 .. l_delete_event_ids.count
                delete from wms_events
                 where id = l_delete_event_ids(i);
        end if;

        execute immediate 'set constraint wms_lse_entries_event_fk immediate';
    exception
        when others then
            begin
                execute immediate 'set constraint wms_lse_entries_event_fk immediate';
            exception
                when others then
                    null;
            end;

            raise;
    end remap_livestack_event;
end wms_livestack_event_pkg;
/
