create or replace PACKAGE BODY       "WMS_PKG_ORDS" as

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████─██████──██████─██████████████─██████──██████─██████████████─████████████████───██████████─██████████████████─██████████████─
-- ─██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░░░░░░░░░░░██───██░░░░░░██─██░░░░░░░░░░░░░░██─██░░░░░░░░░░██─
-- ─██░░██████░░██─██░░██──██░░██─██████░░██████─██░░██──██░░██─██░░██████░░██─██░░████████░░██───████░░████─████████████░░░░██─██░░██████████─
-- ─██░░██──██░░██─██░░██──██░░██─────██░░██─────██░░██──██░░██─██░░██──██░░██─██░░██────██░░██─────██░░██───────────████░░████─██░░██─────────
-- ─██░░██████░░██─██░░██──██░░██─────██░░██─────██░░██████░░██─██░░██──██░░██─██░░████████░░██─────██░░██─────────████░░████───██░░██████████─
-- ─██░░░░░░░░░░██─██░░██──██░░██─────██░░██─────██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░░░██─────██░░██───────████░░████─────██░░░░░░░░░░██─
-- ─██░░██████░░██─██░░██──██░░██─────██░░██─────██░░██████░░██─██░░██──██░░██─██░░██████░░████─────██░░██─────████░░████───────██░░██████████─
-- ─██░░██──██░░██─██░░██──██░░██─────██░░██─────██░░██──██░░██─██░░██──██░░██─██░░██──██░░██───────██░░██───████░░████─────────██░░██─────────
-- ─██░░██──██░░██─██░░██████░░██─────██░░██─────██░░██──██░░██─██░░██████░░██─██░░██──██░░██████─████░░████─██░░░░████████████─██░░██████████─
-- ─██░░██──██░░██─██░░░░░░░░░░██─────██░░██─────██░░██──██░░██─██░░░░░░░░░░██─██░░██──██░░░░░░██─██░░░░░░██─██░░░░░░░░░░░░░░██─██░░░░░░░░░░██─
-- ─██████──██████─██████████████─────██████─────██████──██████─██████████████─██████──██████████─██████████─██████████████████─██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure authorizeORDS(p_content_type varchar2 default 'application/json') as
    v_ords_id varchar2(4000);
    v_ords_secret varchar2(4000);
    v_ords_auth varchar2(4000);
begin
    select value into v_ords_id from wms_system_parameters where name = 'ORDS_ID';
    select value into v_ords_secret from wms_system_parameters where name = 'ORDS_SECRET';
    select value into v_ords_auth from wms_system_parameters where name = 'ORDS_AUTH';
    apex_web_service.oauth_authenticate(
            p_token_url     => v_ords_auth,
            p_client_id     => v_ords_id,
            p_client_secret => v_ords_secret,
            p_proxy_override => null);
    apex_web_service.g_request_headers(1).name  := 'Authorization';
    apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
    if p_content_type is not null then
        apex_web_service.g_request_headers(2).name  := 'Content-Type';
        apex_web_service.g_request_headers(2).value := p_content_type;
    end if;
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████──██████──██████──██████████████──██████──██████──██████████████──████████████████────██████████──██████████████████──██████████████──██████████████──██████──██████──██████████████──██████──────────██████──██████████████──██████████████─
-- ─██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░░░██────██░░░░░░██──██░░░░░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██████░░██──██░░██──██░░██──██████░░██████──██░░██──██░░██──██░░██████░░██──██░░████████░░██────████░░████──████████████░░░░██──██░░██████████──██░░██████████──██░░██──██░░██──██░░██████████──██░░░░░░░░░░██──██░░██──██████░░██████──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──██░░██──██░░██──██░░██──██░░██────██░░██──────██░░██────────────████░░████──██░░██──────────██░░██──────────██░░██──██░░██──██░░██──────────██░░██████░░██──██░░██──────██░░██──────██░░██─────────
-- ─██░░██████░░██──██░░██──██░░██──────██░░██──────██░░██████░░██──██░░██──██░░██──██░░████████░░██──────██░░██──────────████░░████────██░░██████████──██░░██████████──██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██──────██░░██──────██░░██████████─
-- ─██░░░░░░░░░░██──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░░░██──────██░░██────────████░░████──────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██─
-- ─██░░██████░░██──██░░██──██░░██──────██░░██──────██░░██████░░██──██░░██──██░░██──██░░██████░░████──────██░░██──────████░░████────────██░░██████████──██░░██████████──██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██──────██░░██──────██████████░░██─
-- ─██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──██░░██──██░░██──██░░██──██░░██──██░░██────────██░░██────████░░████──────────██░░██──────────██░░██──────────██░░░░██░░░░██──██░░██──────────██░░██──██░░██████░░██──────██░░██──────────────██░░██─
-- ─██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██──██░░██──██░░██████░░██──██░░██──██░░██████──████░░████──██░░░░████████████──██░░██████████──██░░██████████──████░░░░░░████──██░░██████████──██░░██──██░░░░░░░░░░██──────██░░██──────██████████░░██─
-- ─██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░░░░░██──██░░░░░░██──██░░░░░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██────████░░████────██░░░░░░░░░░██──██░░██──██████████░░██──────██░░██──────██░░░░░░░░░░██─
-- ─██████──██████──██████████████──────██████──────██████──██████──██████████████──██████──██████████──██████████──██████████████████──██████████████──██████████████──────██████──────██████████████──██████──────────██████──────██████──────██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure authorizeEventORDS as
    v_ords_id varchar2(4000);
    v_ords_secret varchar2(4000);
    v_ords_auth varchar2(4000);
begin
    select value into v_ords_id from wms_system_parameters where name = 'EVENT_ORDS_CLIENT_ID';
    select value into v_ords_secret from wms_system_parameters where name = 'EVENT_ORDS_CLIENT_SECRET';
    select value into v_ords_auth from wms_system_parameters where name = 'EVENT_ORDS_AUTH';
    apex_web_service.oauth_authenticate(
            p_token_url     => v_ords_auth,
            p_client_id     => v_ords_id,
            p_client_secret => v_ords_secret,
            p_proxy_override => null);
    apex_web_service.g_request_headers(1).name  := 'Authorization';
    apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
end;

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████──────────██████──██████████████──████████████████────██████──████████──██████████████──██████──██████──██████████████──██████████████──██████████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──────────██░░██──██░░░░░░░░░░██──██░░░░░░░░░░░░██────██░░██──██░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░██████░░██──██████░░██████──██░░██████████──██░░██──────────██░░██──██░░██████░░██──██░░████████░░██────██░░██──██░░████──██░░██████████──██░░██──██░░██──██░░██████░░██──██░░██████░░██──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────██░░██──────────██░░██──██░░██──██░░██──██░░██────██░░██────██░░██──██░░██────██░░██──────────██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──██░░██──██████──██░░██──██░░██──██░░██──██░░████████░░██────██░░██████░░██────██░░██████████──██░░██████░░██──██░░██──██░░██──██░░██████░░██──██░░██████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░░░░░░░░░░░██────██░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██████░░████────██░░██████░░██────██████████░░██──██░░██████░░██──██░░██──██░░██──██░░██████████──██████████░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────██░░██████░░██████░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──██░░██────────────██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────────────────██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──██░░░░░░░░░░░░░░░░░░██──██░░██████░░██──██░░██──██░░██████──██░░██──██░░████──██████████░░██──██░░██──██░░██──██░░██████░░██──██░░██──────────██████████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──██░░██████░░██████░░██──██░░░░░░░░░░██──██░░██──██░░░░░░██──██░░██──██░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──────────██░░░░░░░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──██████──██████──██████──██████████████──██████──██████████──██████──████████──██████████████──██████──██████──██████████████──██████──────────██████████████─
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    procedure updateWorkshops as
        v_error_message varchar2(4000);
    begin
        -- Keep the bulk job, but let the single-workshop procedure do the work.
        for thing in (
            select ll.id
              from workshop w,
                   workshop_ll ll
             where w.id = ll.workshop_id
               and (w.updated_flg > 0 or ll.updated_flg = 'Y' or ll.updated_publish_flg > 0)
               and w.workshop_status in ('Completed', 'Quarterly QA', 'Quarterly QA Complete')
               and ll.publish_status in ('Publish Approved', 'Published')
        ) loop
            updateWorkshop(thing.id);
        end loop;
    exception
        when others then
            v_error_message := SQLERRM;
            insert into ords_log(priority, error_message)
            values (1, 'Unhandled exception from updateWorkshops, outside the ORDS call: ' || v_error_message);
    end;
    
    procedure updateWorkshop(
        p_ll_id number
    ) as
        v_body clob;
        v_response clob;
        v_ords_url varchar2(4000);
        v_mrm_url varchar2(1000);
        v_workshop_id number;
        v_updated_publish_flg number;
        v_tags_response boolean;
        v_green_button_response clob;
        v_green_button_enabled varchar2(1000);
        v_error_message varchar2(4000);
    begin
        authorizeORDS;
    
        -- Get endpoint values used by the LiveLabs sync call.
        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';
    
        select value || ':llid=' || p_ll_id
          into v_mrm_url
          from wms_system_parameters
         where name = 'MRM_URL';
    
        select ll.updated_publish_flg
          into v_updated_publish_flg
          from workshop w,
               workshop_ll ll
         where w.id = ll.workshop_id
           and ll.id = p_ll_id
           and w.workshop_status in ('Completed', 'Quarterly QA', 'Quarterly QA Complete')
           and ll.publish_status in ('Publish Approved', 'Published');
    
        -- Preserve the existing LiveLabs Green setting on update calls.
        if v_updated_publish_flg != 2 then
            begin
                v_green_button_response := apex_web_service.make_rest_request(
                    p_url => v_ords_url || 'workshops/read/getWorkshop/' || p_ll_id,
                    p_http_method => 'GET',
                    p_proxy_override => null);
    
                select workshop_json
                  into v_green_button_enabled
                  from json_table(v_green_button_response, '$' columns (workshop_json));
    
                select LiveLabsGreenEnabled
                  into v_green_button_enabled
                  from json_table(
                           v_green_button_enabled,
                           '$' columns (
                               LiveLabsGreenEnabled));
            exception
                when others then
                    v_green_button_enabled := 'N';
            end;
        end if;
    
        -- Build the one-workshop payload, including the new LiveStack Demo URL.
        select
            w.id,
            json_object (
                'livelabs_id' value ll.id,
                'title' value nvl(ll.title_override, w.title),
                'desc_short' value nvl(ll.desc_short_override, w.short_desc),
                'desc_long' value nvl(ll.desc_long_override, w.long_desc),
                'time_in_hours' value ll.workshop_time,
                'active_flg' value case
                    when (ll.alwaysfree_flg = 'N' or ll.alwaysfree_flg is null)
                     and (ll.freetier_flg = 'N' or ll.freetier_flg is null)
                     and (ll.paid_flg = 'N' or ll.paid_flg is null)
                     and (ll.sprint_flg = 'N' or ll.sprint_flg is null)
                     and nvl(v_green_button_enabled, 'N') = 'N'
                     and nvl(ll.greenbutton_flg, 'N') not in ('Y', 'L', 'G')
                     and ll.type_id != (select id from wms_ll_types where name = 'LiveStack Demo')
                    then 'N'
                    else case ll.publish_type
                        when 'Public' then 'Y'
                        when 'Private' then 'U'
                        when 'Event' then 'E'
                        when 'Disabled' then 'N'
                    end
                end,
                'featured_flg' value ll.featured_flg,
                'desc_outline' value nvl(ll.desc_outline_override, w.outline),
                'desc_prerequisites' value nvl(ll.desc_prereq_override, w.prereqs),
                'author_email' value w.workshop_owner_email,
                'ws_owner_group' value w.workshop_owner_group,
                'wms_id' value w.id,
                'lab_url' value '' || json_object (
                    'FREETIER_URL' value case when ll.freetier_url is not null then ll.freetier_url || v_mrm_url else null end,
                    'ALWAYSFREE_URL' value case when ll.alwaysfree_url is not null then ll.alwaysfree_url || v_mrm_url else null end,
                    'PAID_URL' value case ll.sprint_flg when 'Y' then case when ll.sprint_url is not null then ll.sprint_url || v_mrm_url else null end else case when ll.paid_url is not null then ll.paid_url || v_mrm_url else null end end,
                    'LIVELABS_URL' value case when ll.greenbutton_url is not null then ll.greenbutton_url || v_mrm_url else null end,
                    'DESKTOP_GUIDE_URL' value ll.desktopguide_url,
                    'DESKTOP_APP1_URL' value ll.desktopapp1_url,
                    'DESKTOP_APP2_URL' value ll.desktopapp2_url
                ) || '',
                'workshop_json' value '' || json_object (
                    'YoutubeLink' value ll.youtube_link,
                    'AlwaysFreeEnabled' value nvl(ll.alwaysfree_flg, 'N'),
                    'FreeTierEnabled' value nvl(ll.freetier_flg, 'N'),
                    'PaidTenancyEnabled' value nvl(ll.paid_flg, 'N'),
                    'LiveLabsGreenEnabled' value case
                        when ll.type_id = (select id from wms_ll_types where name = 'LiveStack Demo')
                          or nvl(ll.greenbutton_flg, 'N') in ('Y', 'L', 'G')
                        then 'Y'
                        else nvl(v_green_button_enabled, 'N')
                    end,
                    'SprintEnabled' value nvl(ll.sprint_flg, 'N'),
                    'DisplayOciInstructions' value nvl(ll.oci_login_flg, 'N'),
                    'NoVNC' value nvl(ll.novnc_enabled_flg, 'N'),
                    'AdvertEnabled' value 'N',
                    'PrimaryProduct' value nvl((select max(title) from workshop_icons where council_id = w.council_id), 'Other')
                ) || '',
                'type_id' value ll.type_id,
                'livestack_demo_url' value ll.livestack_demo_url
            returning clob)
          into v_workshop_id,
               v_body
          from workshop w,
               workshop_ll ll
         where w.id = ll.workshop_id
           and ll.id = p_ll_id
           and w.workshop_status in ('Completed', 'Quarterly QA', 'Quarterly QA Complete')
           and ll.publish_status in ('Publish Approved', 'Published');
    
        begin
            -- Create new LiveLabs rows, otherwise update the existing row.
            if v_updated_publish_flg = 2 then
                v_response := apex_web_service.make_rest_request(
                    p_url => v_ords_url || 'workshops/write/createWorkshop',
                    p_http_method => 'POST',
                    p_body => v_body,
                    p_proxy_override => null);
            else
                v_response := apex_web_service.make_rest_request(
                    p_url => v_ords_url || 'workshops/write/updateWorkshop/' || p_ll_id,
                    p_http_method => 'PUT',
                    p_body => v_body,
                    p_proxy_override => null);
            end if;
    
            if apex_web_service.g_status_code > 299 then
                insert into ords_log(priority, workshop_id, livelabs_id, error_message, payload)
                values (1, v_workshop_id, p_ll_id, 'Insert/Update Workshop REST error: ' || v_response, v_body);
            else
                if v_updated_publish_flg = 2 then
                    insert into ords_log(priority, workshop_id, livelabs_id, error_message, payload)
                    values (9, v_workshop_id, p_ll_id, 'Insert workshop successful: ' || v_response, v_body);
                else
                    insert into ords_log(priority, workshop_id, livelabs_id, error_message, payload)
                    values (9, v_workshop_id, p_ll_id, 'Update workshop successful', v_body);
                end if;
    
                v_tags_response := updateTags(v_workshop_id, p_ll_id);
                if v_tags_response = true then
                    -- Clear sync flags after the workshop and tags are synced.
                    update workshop
                       set updated_flg = 0
                     where id = v_workshop_id;
    
                    update workshop_ll
                       set updated_publish_flg = 0,
                           updated_flg = 'N',
                           publish_status = 'Published',
                           production_url = 'https://livelabs.oracle.com/ords/dbpm/r/livelabs/view-workshop?wid=' || p_ll_id
                     where id = p_ll_id;
                end if;
            end if;
        exception
            when others then
                v_error_message := SQLERRM;
                insert into ords_log(priority, workshop_id, livelabs_id, error_message, payload)
                values (
                    1,
                    v_workshop_id,
                    p_ll_id,
                    'Unhandled exception from updateWorkshop ORDS call. v_response: ' ||
                    v_response || ' SQLERRM: ' || v_error_message,
                    v_body);
        end;
    exception
        when no_data_found then
            insert into ords_log(priority, livelabs_id, error_message)
            values (1, p_ll_id, 'No eligible workshop found for updateWorkshop.');
        when others then
            v_error_message := SQLERRM;
            insert into ords_log(priority, livelabs_id, error_message)
            values (1, p_ll_id, 'Unhandled exception from updateWorkshop, outside the ORDS call: ' || v_error_message);
    end;

function createCdnLink(p_url varchar2, p_check_exists varchar2 default 'N', p_is_event varchar2 default 'N') return varchar2 is
    v_url varchar2(1000);
    v_response number;
    v_get clob;
    v_tracking_param varchar2(100);
begin
    if (p_url is null) then return null; end if;

    v_url := REGEXP_REPLACE(replace(p_url,'oracle-livelabs.github.io', 'livelabs.oracle.com/cdn'), '\?.*$', '');

    if v_url like '%index' or v_url like '%index/' then
        v_url := v_url || '.html';
    elsif v_url not like '%index.html%' then
        v_url := rtrim(REGEXP_SUBSTR(v_url,'^[^?]+') ,'/') || '/index.html';
    end if;


    if (p_url like '%customTrackingParam=%' and p_is_event = 'Y') then
        v_tracking_param := REGEXP_SUBSTR(p_url,  'customTrackingParam=([^&]+)', 1, 1, NULL, 1);
        v_url := v_url || '?customTrackingParam=' || v_tracking_param;
    end if;

    if (p_check_exists = 'Y') then
        -- Do a check to ensure that the workshop exists.
        v_get := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
            p_url => v_url,
            p_http_method => 'GET'
        );

        v_response := apex_web_service.g_status_code;


        IF v_response BETWEEN 200 AND 399 THEN
            RETURN v_url;
        ELSE
            RETURN p_url;
        END IF;
    else
        RETURN v_url;
    end if;
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████████████──██████████████──██████████████──██████████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░██████░░██──██████░░██████──██░░██████████──██████░░██████──██░░██████░░██──██░░██████████──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██──────────██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██──────────██░░██████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██──██░░██──██████████░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██──██░░██──────────██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──────██░░██──────██░░██──██░░██──██░░██████░░██──██████████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──────██████──────██████──██████──██████████████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
function updateTags(p_workshop_id number, p_ll_id number) return boolean is
    v_tags clob;
    v_response clob;
    v_ords_url varchar2(4000);
begin
    select json_object('tags_hold' value json_arrayagg(json_object('tag_id' value tag_id))returning clob) into v_tags from workshop_tags where workshop_id = p_workshop_id;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
        begin
        v_response := apex_web_service.make_rest_request( p_url => v_ords_url || 'tags/write/updateWorkshopTags/' || p_ll_id,
                                                    p_http_method => 'PUT',
                                                    p_body => v_tags,
                                                    p_proxy_override => null );
        -- log any failures
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, workshop_id, livelabs_id, error_message)
            values (1, p_workshop_id, p_ll_id, 'Insert/Update Tags REST error: ' || v_response);
            return false;
        else
            -- log success
            insert into ords_log(priority, workshop_id, livelabs_id, error_message)
            values (9, p_workshop_id, p_ll_id, 'Tags updated');
        end if;
        exception
        when others then
            insert into ords_log(priority, workshop_id, livelabs_id, error_message)
            values (1, p_workshop_id, p_ll_id, 'Unhandled exception from update tags ORDS call: ' || v_response);
            return false;
        end;
        return true;
exception
    when others then
        insert into ords_log(priority, workshop_id, livelabs_id, error_message)
        values (1, p_workshop_id, p_ll_id, 'Unhandled exception from updateTags, outside the ORDS call.');
        return false;
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████████████──██████████████──██████──────────██████──██████████████──██████──────────██████──██████████████──██████████──██████████████──██████████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██──██░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░██████░░██──██████░░██████──██░░██████████──██████░░██████──██░░██████████──██░░░░░░░░░░██──██░░██──██░░██████░░██──██░░░░░░░░░░██──██░░██──██░░██████████──████░░████──██░░██████████──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──────────██░░██████░░██──██░░██──██░░██──██░░██──██░░██████░░██──██░░██──██░░██────────────██░░██────██░░██──────────██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████████──██░░██──██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██──██░░██────────────██░░██────██░░██████████──██░░██████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──██░░██────────────██░░██────██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████████──██░░██──██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██──██░░██────────────██░░██────██░░██████████──██████████░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──────────██░░██──██░░██████░░██──██░░██──██░░██──██░░██──██░░██████░░██──██░░██────────────██░░██────██░░██──────────────────██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████████──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██████████──████░░████──██░░██████████──██████████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████████░░██──██░░██──██░░██──██░░██──██████████░░██──██░░░░░░░░░░██──██░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──────██████──────██████████████──██████──────────██████──██████──██████──██████──────────██████──██████████████──██████████──██████████████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure updateTenancies as
    v_ords_url varchar2(4000);
    v_response clob;
begin
    -- authroize
    authorizeORDS;
    -- get base ORDS url
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    begin
        v_response := apex_web_service.make_rest_request( p_url => v_ords_url || 'tenancies/read/listTenancies',
                                                        p_http_method => 'GET',
                                                        p_proxy_override => null );
        -- log any failures
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, error_message)
            values (1, 'Update Tenancies REST error: ' || v_response);
        else
            -- update the tenancies table
            merge into ll_tenancies ll
            using (select * from json_table(v_response, '$.items[*]' COLUMNS (id, tenancy_name))) ords
            on (ords.id = ll.id)
            when matched then
                update set ll.tenancy_name = ords.tenancy_name
            when not matched then
                insert (id, tenancy_name)
                values (ords.id, ords.tenancy_name);
            -- log success
            insert into ords_log(priority, error_message)
            values (9, 'Tenancies updated');
        end if;
    exception
        when others then
            insert into ords_log(priority,  error_message)
            values (1, 'Unhandled exception from update tenancies ORDS call: ' || v_response);
    end;
exception
    when others then
        insert into ords_log(priority, error_message)
        values (1, 'Unhandled exception from updateTenancies, outside the ORDS call.');
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████████████──██████──██████──██████████████──██████──────────██████──██████████████──██████████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░██████░░██──██████░░██████──██░░██████████──██░░██████████──██░░██──██░░██──██░░██████████──██░░░░░░░░░░██──██░░██──██████░░██████──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────██░░██──────────██░░██──██░░██──██░░██──────────██░░██████░░██──██░░██──────██░░██──────██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──██░░██████████──██░░██──██░░██──█      ░██████████──██░░██──██░░██──██░░██──────█   ░░██──────██░░███   ██████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░   ██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░░░░░░░░░██──██   ░██──█   ░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──██░░██████████──██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██──────██░░██──────██████████░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────██░░██──────────██░░░░██░░░░██──██░░██──────────██░░   █──██░░██████░░█   ──────██░░██──────────────██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──██░░██████████──████░░░░░░████──██░░██████████──██░░██──██░░░░░░░░░░██──   ───██░░██──────██████████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──██░░░░░   ░░░░██────███   ░░████────██░   ░░░░░░░░██──██░░██──██████████░░██────   ─██░░██──────██░░░░░░░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──██████████████──────██████──────██████████████──██████──────────██████──────██████──────██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure updateEventCodes as
    v_ords_url varchar2(4000);
    v_response clob;
    v_body clob;
    v_err varchar2(4000);
    v_alt_cdn_url varchar2(4000) := null;
    cursor c_events is select *
                        from wms_events
                        where event_status in ('Event Published', 'Event Approved')
                        and updated_flg > 0;
begin
    -- authroize
    authorizeORDS;
    -- get base ORDS url
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    -- go through updated events
    for event in c_events loop

        apex_web_service.g_status_code := null;
        if (event.github_override_flg = 'N') then
            v_alt_cdn_url := json_object(
                'FREETIER_URL' value null,
                'LIVELABS_URL' value WMS_PKG_ORDS.createCDNLink(JSON_VALUE(event.alt_url, '$.LIVELABS_URL'), 'Y'),
                'ALWAYSFREE_URL' value null,
                'PAID_URL' value WMS_PKG_ORDS.createCDNLink(JSON_VALUE(event.alt_url, '$.PAID_URL'), 'Y'),
                'LIVESQL_URL' value WMS_PKG_ORDS.createCDNLink(JSON_VALUE(event.alt_url, '$.LIVESQL_URL'), 'Y'));
        else
            v_alt_cdn_url := event.alt_url;
        end if;


        v_body := json_object(
            'event_id' value event.id,
            'title' value event.title,
            'email_creator' value event.email_creator,
            'email_requestor' value event.email_requestor,
            'valid_from' value to_char(event.valid_from, 'MM/DD/YYYY'),
            'valid_to' value to_char(event.valid_to, 'MM/DD/YYYY'),
            'users_maximum' value event.users_maximum,
            'workshop_id' value event.livelabs_id,
            'alt_desc_long' value event.alt_desc_long,
            'alt_desc_outline' value event.alt_desc_outline,
            'alt_desc_prerequisites' value event.alt_desc_prereq,
            'alt_desc_short' value event.alt_desc_short,
            'active_flg' value event.active_flg,
            'valid_timezone' value event.valid_timezone,
            'alt_url' value v_alt_cdn_url,
            'tenancy_id' value event.tenancy_id,
            'users_concurrent' value event.users_concurrent,
            'alt_time_hours' value event.alt_time_hours,
            'alt_time_available' value event.alt_time_available,
            'display_tags' value event.display_tags,
            'event_json' value event.event_json,
            'event_config_json' value event.event_config_json
        );
        begin
            if event.updated_flg = 2 then
                v_response := apex_web_service.make_rest_request(
                      p_url            => v_ords_url || 'events/write/createEvent',
                      p_http_method    => 'POST',
                      p_body           => v_body,
                      p_proxy_override => null);
            elsif event.updated_flg = 1 then
               v_response := apex_web_service.make_rest_request(
                      p_url            => v_ords_url || 'events/write/updateEvent/' || event.id,
                      p_http_method    => 'PUT',
                      p_body           => v_body,
                      p_proxy_override => null);
            else
                insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                values (1, event.id, event.livelabs_id, 'Unexpected updated_flg: ' || event.updated_flg);
                raise_application_error(-20001, 'Invalid updated_flg');
            end if;

            if apex_web_service.g_status_code between 200 and 299 then

                if (event.updated_flg = 2) and (v_response is not null) then
                    update wms_events
                       set updated_flg = 0,
                           event_status = 'Event Published',
                           event_code = (select Event_Code
                                           from json_table(v_response, '$' columns (Event_Code)))
                     where id = event.id
                     and event_code is null;

                    insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                    values (9, event.id, event.livelabs_id, 'Event insert success: ' || v_response);
                elsif v_response is null then
                    insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                    values (1, event.id, event.livelabs_id,
                        'Event insert REST error: v_response is null. Status=' || apex_web_service.g_status_code || ', Response=' || v_response);
                end if;


                if event.updated_flg = 1 then
                    -- reset updated flag and status
                    update wms_events
                       set updated_flg = 0,
                           event_status = 'Event Published'
                     where id = event.id;

                    insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                    values (9, event.id, event.livelabs_id, 'Event update success.');
                end if;
            else
                insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                values (1, event.id, event.livelabs_id,
                        'Event REST error. Status=' || apex_web_service.g_status_code || ', Response=' || v_response);
            end if;

        exception
            when others then
                v_err := sqlerrm;
                insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                values (1, event.id, event.livelabs_id, 'REST exception: ' || v_err);
                raise;
        end;

    end loop;
exception
    when others then
        v_err := SQLERRM;
        insert into ords_log(priority, error_message)
        values (1, 'Unhandled exception from updateEvents, outside the ORDS call : ' || v_err);
end;


-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████████──██████████████──██████████████──██████──────────██████──██████████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░██████░░██──██████░░██████──██░░██████████──████░░████──██░░██████████──██░░██████░░██──██░░░░░░░░░░██──██░░██──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██────────────██░░██────██░░██──────────██░░██──██░░██──██░░██████░░██──██░░██──██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████────██░░██────██░░██──────────██░░██──██░░██──██░░██──██░░██──██░░██──██░░██████████─
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██────██░░██────██░░██──────────██░░██──██░░██──██░░██──██░░██──██░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████────██░░██────██░░██──────────██░░██──██░░██──██░░██──██░░██──██░░██──██████████░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██────────────██░░██────██░░██──────────██░░██──██░░██──██░░██──██░░██████░░██──────────██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──████░░████──██░░██████████──██░░██████░░██──██░░██──██░░░░░░░░░░██──██████████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──██░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██████████░░██──██░░░░░░░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──██████████──██████████████──██████████████──██████──────────██████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure updateIcons as
    cursor c_icon is select id, title, icon_blob, youtube_link from workshop_icons;
    v_response clob;
    v_ords_url varchar2(4000);
begin

    wms_pkg_ords.authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';

    for icon in c_icon loop
        apex_web_service.g_request_headers(2).name  := 'Content-Type';
        apex_web_service.g_request_headers(2).value := 'image/png';
        apex_web_service.g_request_headers(3).name  := 'icon_id';
        apex_web_service.g_request_headers(3).value := icon.id;
        apex_web_service.g_request_headers(4).name  := 'icon_title';
        apex_web_service.g_request_headers(4).value := icon.title;
        apex_web_service.g_request_headers(5).name  := 'youtube_link';
        apex_web_service.g_request_headers(5).value := icon.youtube_link;

        begin
            v_response := apex_web_service.make_rest_request(
                p_url => v_ords_url || 'admin/updateIcons',
                p_http_method => 'PUT',
                p_body_blob => icon.icon_blob,
                p_proxy_override => null
            );
            if apex_web_service.g_status_code > 299 then
                insert into ords_log(priority, workshop_id, error_message)
                values (1, icon.id,  'Update Icon REST error: ' || v_response);
            end if;
        exception when others then
            insert into ords_log(priority, workshop_id, error_message)
            values (1, icon.id, 'Update Icon REST Error: ' || v_response);
        end;

    end loop;

    insert into ords_log(priority, error_message)
    values (9,  'Update Icons Successful');

exception when others then
    insert into ords_log(priority, error_message)
    values (1, 'Unhandled exception from UpdateIcons, outside the ORDS call.');
end;

-- ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████─██████████████─██████████████────██████████████─██████──██████─██████████████─██████──────────██████─██████████████─██████████████─
-- ─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██────██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░██████████──██░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
-- ─██░░██████████─██░░██████████─██████░░██████────██░░██████████─██░░██──██░░██─██░░██████████─██░░░░░░░░░░██──██░░██─██████░░██████─██░░██████████─
-- ─██░░██─────────██░░██─────────────██░░██────────██░░██─────────██░░██──██░░██─██░░██─────────██░░██████░░██──██░░██─────██░░██─────██░░██─────────
-- ─██░░██─────────██░░██████████─────██░░██────────██░░██████████─██░░██──██░░██─██░░██████████─██░░██──██░░██──██░░██─────██░░██─────██░░██████████─
-- ─██░░██──██████─██░░░░░░░░░░██─────██░░██────────██░░░░░░░░░░██─██░░██──██░░██─██░░░░░░░░░░██─██░░██──██░░██──██░░██─────██░░██─────██░░░░░░░░░░██─
-- ─██░░██──██░░██─██░░██████████─────██░░██────────██░░██████████─██░░██──██░░██─██░░██████████─██░░██──██░░██──██░░██─────██░░██─────██████████░░██─
-- ─██░░██──██░░██─██░░██─────────────██░░██────────██░░██─────────██░░░░██░░░░██─██░░██─────────██░░██──██░░██████░░██─────██░░██─────────────██░░██─
-- ─██░░██████░░██─██░░██████████─────██░░██────────██░░██████████─████░░░░░░████─██░░██████████─██░░██──██░░░░░░░░░░██─────██░░██─────██████████░░██─
-- ─██░░░░░░░░░░██─██░░░░░░░░░░██─────██░░██────────██░░░░░░░░░░██───████░░████───██░░░░░░░░░░██─██░░██──██████████░░██─────██░░██─────██░░░░░░░░░░██─
-- ─██████████████─██████████████─────██████────────██████████████─────██████─────██████████████─██████──────────██████─────██████─────██████████████─
-- ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure getEventCodes as
v_response clob;
v_test clob;
v_event_ords_url varchar2(4000);
v_continue boolean := true;
begin
    authorizeEventORDS;
    select value into v_event_ords_url from wms_system_parameters where name = 'EVENT_ORDS_URL';
    while v_continue loop
        v_response := apex_web_service.make_rest_request(
            p_url => v_event_ords_url,
            p_http_method => 'GET',
            p_proxy_override => null
        );
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, error_message)
            values (1,  'Get Event Codes REST error: ' || v_response);
        else
            merge into wms_events wms
                using (select * from json_table(v_response, '$.items[*]' columns (id, lab_id, event_title, event_organizer, event_location, youtube_link, start_date date, end_time date, timezone, max_users number, reg_users number, outline, short_desc, long_desc, prereqs, green_button_flg, your_tenancy_flg, lab_alt_time_avail number, lab_comments))) json
                on (wms.community_event_id = json.id)
            when matched then
                update set wms.title = json.event_title, wms.livelabs_id = json.lab_id, wms.email_creator = json.event_organizer, wms.valid_from = json.start_date -2 , wms.valid_to = json.end_time+2, wms.valid_timezone = 'UTC',
                wms.users_maximum = case json.max_users when -1 then 200 else json.max_users end, wms.users_concurrent = case when json.reg_users < 10 then 10 else json.reg_users end, wms.alt_desc_outline = json.outline, wms.alt_desc_long = json.long_desc, wms.alt_desc_short = json.short_desc, wms.alt_desc_prereq = json.prereqs,
                wms.event_json = json_object('LiveLabsGreenEnabled' value json.green_button_flg, 'PaidTenancyEnabled' value json.your_tenancy_flg, 'YoutubeLink' value json.youtube_link, 'EventLocation' value json.event_location),
                wms.alt_time_available = json.lab_alt_time_avail, wms.alt_time_hours = json.lab_alt_time_avail, wms.remarks = json.lab_comments, wms.updated_flg = case wms.updated_flg when 2 then 2 else 1 end, wms.event_status = case wms.event_status when 'Event Published' then 'Event Published' else 'Event Approved' end
            when not matched then
                insert (community_event_id, title, email_creator, valid_from, valid_to, users_maximum, users_concurrent, livelabs_id, alt_desc_long, alt_desc_short, alt_desc_outline, alt_desc_prereq, valid_timezone, event_json, alt_time_available, alt_time_hours, remarks, updated_flg, display_tags, active_flg, event_status)
                values (json.id, json.event_title, json.event_organizer,json.start_date-2, json.end_time+2, case json.max_users when -1 then 200 else json.max_users end, case when json.reg_users < 10 then 10 else json.reg_users end, json.lab_id, json.long_desc, json.short_desc, json.outline, json.prereqs, 'UTC', json_object('LiveLabsGreenEnabled' value json.green_button_flg, 'PaidTenancyEnabled' value json.your_tenancy_flg, 'YoutubeLink' value json.youtube_link, 'EventLocation' value json.event_location), json.lab_alt_time_avail, json.lab_alt_time_avail, json.lab_comments, 2, 'Y', 'Y', 'Event Approved');

            merge into wms_events wms
            using workshop_ll ll
            on (wms.livelabs_id = ll.id)
            when matched then
                update set wms.alt_url = json_object('PAID_URL' value ll.paid_url,
                                            'LIVELABS_URL' value ll.greenbutton_url)
                    where wms.alt_url is null
                        and wms.community_event_id is not null
                        and wms.valid_from > sysdate;
            -- see if there are more events to get
            insert into ords_log(priority, error_message)
            values (9,  v_response);
            if json_value(v_response, '$.next.*') is not null then
                v_event_ords_url := json_value(v_response, '$.next.*');
            else
                v_continue := false;
            end if;
        end if;
    end loop;
    -- log success
    insert into ords_log(priority, error_message)
    values (9,  'Get Event Codes Success');
exception when others then
    insert into ords_log(priority, error_message)
    values (1, 'Unhandled exception from getEventCodes, outside the ORDS call.');
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████──██████──██████──██████████████──██████──██████──██████████████──██████──██████──██████████████──██████──────────██████──██████████████──██████████████─
-- ─██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██████░░██──██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████████──██░░░░░░░░░░██──██░░██──██████░░██████──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──────────██░░██──██░░██──██░░██──────────██░░██████░░██──██░░██──────██░░██──────██░░██─────────
-- ─██░░██████░░██──██░░██──██░░██──██░░██████████──██░░██████░░██──██░░██████████──██░░██──██░░██──██░░██████   ███──██░░██──██░░██──██░░██──────██░░██──────██░░██████████─
-- ─██░░░░░░░░░░██──██░░██──██░░   █──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──────██░░██──────██░░   ░░░░░░░██─
-- ─██░░██████████──██░░██──██░░██──██████████░░██──██░░██████░░██──██░░   █████████──██░░██──██   ░██─   ██   ░██████████──██░   ██──██░░██──██░░██──────██░░██──────██████████░░██─
-- ─██░░██──────────██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────────██░░░░██░░░░██──██░░██──────────██░░██──██░░██████░░██──────██░░██─   ────────────██░░██─
-- ─██░░██──────────██░░██████░░██──██████████░░██──██░░██──██░░██──██░░██████████──████░░░░░░████──██░░██████████──██░░██──██░░░░░░░░░░██──────██░░██──────██████████░░██─
-- ─██░░██──────────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██────████░░████────██░░░░░░░░░░██──██░░██──██████████░░██──────██░░██──────██░░░░░░░░░░██─
-- ─██████──────────██████████████──██████████   ███──██████──██████──██████████████──────██████──────██████████   ███──██████──────────█████   ──────██████──────██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure pushEventCodes as
    cursor c_events is select *
                        from wms_events
                        where event_status in ('Event Published')
                        and updated_flg = 0
                        and valid_to > sysdate
                        and community_event_id is not null;
    v_body clob;
    v_response clob;
    v_event_ords_url varchar2(4000);
begin
    authorizeEventORDS;
    select value into v_event_ords_url from wms_system_parameters where name = 'EVENT_ORDS_URL';
    for event in c_events loop
        v_body := json_object(
            'event_lab_code' value event.event_code
        );
        -- v_body := '{"event_lab_code":"' || event.event_code || '"}';
        v_response := apex_web_service.make_rest_request(
            p_url => v_event_ords_url || '/' || event.community_event_id,
            p_http_method => 'PUT',
            p_body => v_body,
            p_proxy_override => null
        );
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, error_message)
            values (1,  'Push Event Codes REST error: ' || v_response);
        else
            insert into ords_log(priority, error_message)
            values (9,  'Push Event Codes REST success: ' || v_response || v_body);
        end if;
    end loop;
exception when others then
    insert into ords_log(priority, error_message)
    values (1, 'Unhandled exception from pushEventCodes');
end;

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████──████████████████────██████████████──██████████████──██████████████──██████████████──██████████████──████████████████────██████████████──██████████████──██████──────────██████──██████████████────██████──██████──██████████████──██████████████──██████████████──██████──────────██████─
-- ─██░░░░░░░░░░██──██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██████████──██░░██──██░░░░░░░░░░██────██░░██──██░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██████████──██░░██─
-- ─██░░██████████──██░░████████░░██────██░░██████████──██░░██████░░██──██████░░██████──██░░██████████──██░░██████████──██░░████████░░██────██░░██████████──██░░██████████──██░░░░░░░░░░██──██░░██──██░░██████░░██────██░░██──██░░██──██████░░██████──██████░░██████──██░░██████░░██──██░░░░░░░░░░██──██░░██─
-- ─██░░██──────────██░░██────██░░██────██░░██──────────██░░██──██░░██──────██░░██──────██░░██──────────██░░██──────────██░░██────██░░██────██░░██──────────██░░██──────────██░░██████░░██──██░░██──██░░██──██░░██────██░░██──██░░██──────██░░██──────────██░░██──────██░░██──██░░██──██░░██████░░██──██░░██─
-- ─██░░██──────────██░░████████░░██────██░░██████████──██░░██████░░██──────██░░██──────██░░██████████──██░░██──────────██░░████████░░██────██░░██████████──██░░██████████──██░░██──██░░██──██░░██──██░░██████░░████──██░░██──██░░██──────██░░██──────────██░░██──────██░░██──██░░██──██░░██──██░░██──██░░██─
-- ─██░░██──────────██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████──██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░██──██░░░░░░░░░░░░██──██░░██──██░░██──────██░░██──────────██░░██──────██░░██──██░░██──██░░██──██░░██──██░░██─
-- ─██░░██──────────██░░██████░░████────██░░██████████──██░░██████░░██──────██░░██──────██░░██████████──██░░██──██░░██──██░░██████░░████────██░░██████████──██░░██████████──██░░██──██░░██──██░░██──██░░████████░░██──██░░██──██░░██──────██░░██──────────██░░██──────██░░██──██░░██──██░░██──██░░██──██░░██─
-- ─██░░██──────────██░░██──██░░██──────██░░██──────────██░░██──██░░██──────██░░██──────██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────────██░░██──────────██░░██──██░░██████░░██──██░░██────██░░██──██░░██──██░░██──────██░░██──────────██░░██──────██░░██──██░░██──██░░██──██░░██████░░██─
-- ─██░░██████████──██░░██──██░░██████──██░░██████████──██░░██──██░░██──────██░░██──────██░░██████████──██░░██████░░██──██░░██──██░░██████──██░░██████████──██░░██████████──██░░██──██░░░░░░░░░░██──██░░████████░░██──██░░██████░░██──────██░░██──────────██░░██──────██░░██████░░██──██░░██──██░░░░░░░░░░██─
-- ─██░░░░░░░░░░██──██░░██──██░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░██──██████████░░██──██░░░░░░░░░░░░██──██░░░░░░░░░░██──────██░░██──────────██░░██──────██░░░░░░░░░░██──██░░██──██████████░░██─
-- ─██████████████──██████──██████████──██████████████──██████──██████──────██████──────██████████████──██████████████──██████──██████████──██████████████──██████████████──██████──────────██████──████████████████──██████████████──────██████──────────██████──────██████████████──██████──────────██████─
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure createGreenButton as
    v_ords_url varchar2(4000);
    v_response clob; -- What does an ORDS response typically look like
    v_body clob;
    cursor c_requests is select *
                        from green_button_lite
                        where updated_flg = 1
                        and ll_id in (select id from workshop_ll where greenbutton_flg = 'L');-- New Entries + Updated Entries
begin
    -- authroize
    authorizeORDS;
    -- get base ORDS url
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL'; -- This allows it to work in multiple environments
    -- go through updated requests
    for request in c_requests loop
        v_body := json_object(
            'LL_ID' value request.LL_ID,
            'WMS_ID' value request.WMS_ID,
            'ADW' value request.ADW,
            'ADW_OCPU' value request.ADW_OCPU,
            'ADW_TB' value request.ADW_TB,
            'ATP' value request.ATP,
            'ATP_OCPU' value request.ATP_OCPU,
            'ATP_TB' value request.ATP_TB,
            'AJD' value request.AJD,
            'AJD_OCPU' value request.AJD_OCPU,
            'AJD_TB' value request.AJD_TB,
            'COMP_INST' value request.COMP_INST,
            'COMP_INST_OCPU' value request.COMP_INST_OCPU,
            'VCN' value request.VCN,
            'OCS' value request.OCS,
            'UPDATED_FLG' value request.UPDATED_FLG
        );
        begin

            v_response := apex_web_service.make_rest_request( p_url => v_ords_url || 'greenbutton/createGreenButton',
                                                            p_http_method => 'POST',
                                                            p_body => v_body,
                                                            p_proxy_override => null );
            -- log any failures
            if apex_web_service.g_status_code > 299 then
                if SQLCODE = -20987 then
                    insert into ords_log(priority, error_message)
                    values (1, 'No Green Button Lite requests to process.');
                else
                    insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                    values (1, request.WMS_ID, request.LL_ID, 'Insert/Update Green Button REST error: ' || v_response);
                end if;
            else
            -- log success
                insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                values (9, request.WMS_ID, request.LL_ID, 'Insert/Update Green Button successful: ' || v_response);
            -- reset the updated flag to 0
                update green_button_lite set updated_flg = 0 where LL_ID = request.LL_ID;
            --set the GB flag to 'L'
                update workshop_ll set greenbutton_flg = 'L' where ID = request.LL_ID;

            end if;
        exception
            when others then
                insert into ords_log(priority, workshop_id, livelabs_id, error_message)
                values (1, request.WMS_ID, request.LL_ID, 'Unhandled exception from create Green Button ORDS call: ' || v_response);
        end;
    end loop;
exception
    when others then
        if SQLCODE = -20987 then
            insert into ords_log(priority, error_message)
            values (1, 'No Green Button Lite requests to process.');
        else
            insert into ords_log(priority, error_message)
            values (1, 'Unhandled exception from createGreenButton, outside the ORDS call.');
        end if;
end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─██████████████──████████████████────██████████████──██████████████──██████████████──██████████████──██████████████──██████████████──██████████████─
-- ─██░░░░░░░░░░██──██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██████████──██░░████████░░██────██░░██████████──██░░██████░░██──██████░░██████──██░░██████████──██████░░██████──██░░██████░░██──██░░██████████─
-- ─██░░██──────────██░░██────██░░██────██░░██──────────██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██─────────
-- ─██░░██──────────██░░████████░░██────██░░██████████──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██─────────
-- ─██░░██──────────██░░░░░░░░░░░░██────██░░░░░░░░░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████─
-- ─██░░██──────────██░░██████░░████────██░░██████████──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██──██░░██─
-- ─██░░██──────────██░░██──██░░██──────██░░██──────────██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██──██░░██─
-- ─██░░██████████──██░░██──██░░██████──██░░██████████──██░░██──██░░██──────██░░██──────██░░██████████──────██░░██──────██░░██──██░░██──██░░██████░░██─
-- ─██░░░░░░░░░░██──██░░██──██░░░░░░██──██░░░░░░░░░░██──██░░██──██░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░██──██░░██──██░░░░░░░░░░██─
-- ─██████████████──██████──██████████──██████████████──██████──██████──────██████──────██████████████──────██████──────██████──██████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure createTag(p_tag_id number, p_level1 varchar2, p_level2 varchar2, p_level3 varchar2) as
v_response clob;
v_body clob;
begin

    v_body := json_object(
        'tag_id'     value  p_tag_id,
        'level1' value  p_level1,
        'level2' value  p_level2,
        'level3' value  p_level3
    );
    begin
        -- dev
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://livelabs-dev.oracle.com/ords/dbpm/oauth/token',
            p_client_id     => '9VOD22C3mjb7SrrceqF10g..',
            p_client_secret => 'YwtXRCoGxl_jF_CMfXHUww..',
            p_proxy_override => null);
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        apex_web_service.g_request_headers(2).name  := 'Content-Type';
        apex_web_service.g_request_headers(2).value := 'application/json';
        v_response := apex_web_service.make_rest_request( p_url => 'https://livelabs-dev.oracle.com/ords/dbpm/livelabs/tags/write/createTag',
                                                                    p_http_method => 'POST',
                                                                    p_body => v_body,
                                                                    p_proxy_override => null );
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, workshop_id, error_message)
            values (1, p_tag_id, 'Dev Create Tag REST error: ' || v_response || ' body: ' || v_body);
        else
            insert into ords_log(priority, workshop_id, error_message)
            values (9, p_tag_id, 'Dev Create Tag Success: ' || v_response);
        end if;
        -- stage
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://livelabs-stg.oracle.com/ords/dbpm/oauth/token',
            p_client_id     => 'LDvuUnC24oPJp5Tj2ZGHSA..',
            p_client_secret => 'if66BHfnaL4Hedb-dpyG_w..',
            p_proxy_override => null);
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        v_response := apex_web_service.make_rest_request( p_url => 'https://livelabs-stg.oracle.com/ords/dbpm/livelabs/tags/write/createTag',
                                                                    p_http_method => 'POST',
                                                                    p_body => v_body,
                                                                    p_proxy_override => null );
        if apex_web_service.g_status_code > 299  then
            insert into ords_log(priority, workshop_id, error_message)
            values (1, p_tag_id, 'Stage Create Tag REST error: ' || v_response);
        else
            insert into ords_log(priority, workshop_id, error_message)
            values (9, p_tag_id, 'Stage Create Tag Success: ' || v_response);
        end if;
        -- Prod
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://livelabs.oracle.com/ords/dbpm/oauth/token',
            p_client_id     => 'FSYfEJXO6n69DhB7SBe3rQ..',
            p_client_secret => 'BxRgtEgUBvs9E2cY_BE8yw..',
            p_proxy_override => null);
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        v_response := apex_web_service.make_rest_request( p_url => 'https://livelabs.oracle.com/ords/dbpm/livelabs/tags/write/createTag',
                                                                    p_http_method => 'POST',
                                                                    p_body => v_body,
                                                                    p_proxy_override => null );
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, workshop_id, error_message)
            values (1, p_tag_id, 'Prod Create Tag REST error: ' || v_response);
        else
            insert into ords_log(priority, workshop_id, error_message)
            values (9, p_tag_id, 'Prod Create Tag Success: ' || v_response);
        end if;
    exception when others then
        insert into ords_log(priority, error_message)
        values (1, 'Unhandled exception from creatTag, inside the ORDS call. Response: ' || v_response);
    end;
exception when others then
    insert into ords_log(priority, error_message)
    values (1, 'Unhandled exception from creatTag, outside the ORDS call.');
end;

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────   ─────────────────
-- ─██████──██████──██████████████──████████████────██████████████──██████████████──██████████████──██████████████──██████████████──██████████████─
-- ─██░   ██──██░░██──██░░░░░░░░░░██──██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░██──██░░██──██░░██████░░██──██░░████░░░░██──██░░   █████░░██──██████░░██████──██░░██████████──██████░░██████──██░░██████░░██──██░░██████████─
-- ─██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──██░░██──────██░░██──   ───██░░██──────────────██░░██──────██░░██──██░░██──██░░██─────────
-- ─██░░██──██░░██──██░░██████░░██──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██─────────
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──██░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████─
-- ─██░░██──██░░██──██░░██████████──██░░██──██░░██──██░░██████░░██──────██░░██──────██░░██████████──────██░░██──────██░░██████░   ██──██░░██──██░░██─
-- ─██░   ██──██░░██──██░░██──────────██░░██──██░░██──██░░██──██░░██──────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██──██░░██─
-- ─██░░██████░░██──██░░██──────────██░░████░░░░██──██░░██──██░░██──────██░░██──────██░░██████████──────██░░██──────██░░██──██░░██──██░░██████░░██─
-- ─██░░░░░░░░░░██──██░░██──────────██░░░░░░░░████──██░░██──██░░██───   ──██░░██──────██░░░░░░░░░░██──────██░░██──────██░░██──██░░██──██░░░░░   ░░░░██─
-- ─██████████████──██████──────────████████████────██████──██████──────██████──────██████████████──────██████──────██████──██████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure updateTag(p_tag_id number, p_level1 varchar2, p_level2 varchar2, p_level3 varchar2) as
v_response clob;
v_body clob;
begin

    v_body := json_object(
        'tag_id'     value  p_tag_id,
        'level1' value  p_level1,
        'level2' value  p_level2,
        'level3' value  p_level3
    );
        -- dev
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://livelabs-dev.oracle.com/ords/dbpm/oauth/token',
            p_client_id     => 'cN3-BCgL_YYin4U30s_4UQ..',
            p_client_secret => 'XZahScC6_Uv4hPrWX3b0Mw..',
            p_proxy_override => null);
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        v_response := apex_web_service.make_rest_request( p_url => 'https://livelabs-dev.oracle.com/ords/dbpm/livelabs/tags/write/updateTag',
                                                                    p_http_method => 'PUT',
                                                                    p_body => v_body,
                                                                    p_proxy_override => null );

end;

-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ─████████████────██████████████──██████──────────██████████████──██████████████──██████████████──██████████████──██████████████──██████████████─
-- ─██░░░░░░░░████──██░░░░░░░░░░██──██░░██──────────██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██─
-- ─██░░████░░░░██──██░░██████████──██░░██──────────██░░██████████──██████░░██████──██░░██████████──██████░░██████──██░░██████░░██──██░░██████████─
-- ─██░░██──██░░██──██░░██──────────██░░██──────────██░░██──────────────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██─────────
-- ─██░░██──██░░██──██░░██████████──██░░██──────────██░░██████████──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██─────────
-- ─██░░██──██░░██──██░░░░░░░░░░██──██░░██──────────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──██░░██──██████─
-- ─██░░██──██░░██──██░░██████████──██░░██──────────██░░██████████──────██░░██──────██░░██████████──────██░░██──────██░░██████░░██──██░░██──██░░██─
-- ─██░░██──██░░██──██░░██──────────██░░██──────────██░░██──────────────██░░██──────██░░██──────────────██░░██──────██░░██──██░░██──██░░██──██░░██─
-- ─██░░████░░░░██──██░░██████████──██░░██████████──██░░██████████──────██░░██──────██░░██████████──────██░░██──────██░░██──██░░██──██░░██████░░██─
-- ─██░░░░░░░░████──██░░░░░░░░░░██──██░░░░░░░░░░██──██░░░░░░░░░░██──────██░░██──────██░░░░░░░░░░██──────██░░██──────██░░██──██░░██──██░░░░░░░░░░██─
-- ─████████████────██████████████──██████████████──██████████████──────██████──────██████████████──────██████──────██████──██████──██████████████─
-- ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
procedure deleteTag(p_tag_id number) as
v_response clob;
v_body clob;
begin

        -- dev
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://livelabs-dev.oracle.com/ords/dbpm/oauth/token',
            p_client_id     => 'cN3-BCgL_YYin4U30s_4UQ..',
            p_client_secret => 'XZahScC6_Uv4hPrWX3b0Mw..',
            p_proxy_override => null);
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        v_response := apex_web_service.make_rest_request( p_url => 'https://livelabs-dev.oracle.com/ords/dbpm/livelabs/tags/write/deleteTag/'|| p_tag_id,
                                                                    p_http_method => 'DELETE',
                                                                    p_proxy_override => null );

end;

procedure getEventAttends as
    cursor c_update_events_from_livelabs is select *
                        from wms_events
                        where event_status in ('Event Published')
                        and ((sysdate > valid_from and sysdate < valid_to )
                          or  (sysdate > valid_to and sysdate-7 < valid_to));

    v_body clob;
    v_response clob;
    v_ords_url varchar2(4000);
    v_exists number;

begin
    wms_pkg_ords.authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    for event in c_update_events_from_livelabs loop
        v_response := apex_web_service.make_rest_request(
            p_url => v_ords_url || 'events/read/getEventAttendees/' || event.id,
            p_http_method => 'GET',
            p_proxy_override => null
        );
        if apex_web_service.g_status_code > 299 then
            insert into ords_log(priority, error_message)
            values (1,  'GET EventAttendees Error: ' ||v_response);
        else
            begin
                select event_attendees into v_exists from wms_event_attendees where event_id = event.id;
                update wms_event_attendees set event_attendees = json_value(v_response,'$.event_lab_code_result') where event_id = event.id;
            exception
                when no_data_found then
                    insert into wms_event_attendees(event_attendees, event_id)
                    values(json_value(v_response,'$.event_lab_code_result'),event.id);
                when others then
                    insert into ords_log(priority, error_message)
                    values (1,  'Error inserting/updating event attendees for event ' || event.id);
            end;
        end if;
    end loop;
    insert into ords_log(priority, error_message)
    values (9,  'GET EventAttendees completed');
EXCEPTION
    WHEN others THEN
        insert into ords_log(priority, error_message)
        values (1,  'Unhandled exception in GET EventAttendees');
end;

procedure putEventAttends as

  cursor c_push_events_to_marcie is select *
                      from wms_events
                       where event_status in ('Event Published')
                        and ((sysdate > valid_from and sysdate < valid_to )
                        or  (sysdate > valid_to and sysdate-7 < valid_to))
                        and community_event_id is not null;
    v_body clob;
    v_response clob;
    v_ords_url varchar2(4000);
    v_results number;

begin
    authorizeEventORDS;
    select value into v_ords_url from wms_system_parameters where name = 'EVENT_ORDS_URL';
    for event in c_push_events_to_marcie loop
        begin
            select event_attendees into v_results from wms_event_attendees where event_id = event.id;
            v_body := json_object('event_lab_code_result' value v_results);
            v_response := apex_web_service.make_rest_request(
                p_url => substr(v_ords_url,0,length(v_ords_url)-6) || 'results/' || event.community_event_id,
                p_http_method => 'PUT',
                p_body => v_body,
                p_proxy_override => null);

            if apex_web_service.g_status_code > 299 then
                insert into ords_log(priority, error_message)
                values (1,  'Event attendees PUT error: ' || v_response);
            else
                insert into ords_log(priority, error_message)
                values (9,  'Event attendees PUT success: ' || v_response || v_body);
            end if;
        EXCEPTION
            WHEN no_data_found then
                insert into ords_log(priority, error_message)
                values (1,  'No Event Attendees for event id : '|| event.id);
        end;
    end loop;
EXCEPTION
    WHEN others THEN
        insert into ords_log(priority, error_message)
        values (1, 'Unhandled exception from pushEventCodes');
end;

procedure import_image(p_tenancy_id number, p_compartment_ocid varchar2, p_image_name varchar2, p_uri varchar2, response out varchar2) as
    v_ords_url varchar2(4000);
    v_body clob;
begin
    authorizeEventORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';

            v_body := json_object('tenancy_id' value p_tenancy_id,
                                  'compartment_ocid' value p_compartment_ocid,
                                  'image_name' value p_image_name,
                                  'object_storage_uri' value p_uri);
            response := apex_web_service.make_rest_request(p_url => v_ords_url || 'images/import_image',
                                                    p_http_method => 'POST',
                                                    p_body => v_body,
                                                    p_proxy_override => null);
end;

procedure createImage(p_image_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select json_object(
         'image_id'        value p_image_id,
         'listing_id'      value listing_id,
         'remarks'         value remarks,
         'seclist_req'     value seclist_req,
         'ocpu_req'        value ocpu_required,
         'image_req'       value image_req,
         'pubkey_req'      value pubkey_req,
         'novnc_enabled'   value novnc_enabled,
         'database_version' value database_version,
         'version'         value version,
         'instance_prefix' value instance_prefix,
         'image_ocid'      value image_ocid,
         'active_flg'      value 'Y',
         'added_on'        value added_on,
         'added_by'        value added_by
         null on null
         returning clob
       )
    into   v_body
    from   omp_images
    where  id = p_image_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/createImage',
                                            p_http_method => 'POST',
                                            p_body => v_body,
                                            p_proxy_override => null);

    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;
    dbms_output.put_line(response);
    update omp_images set updated_flg = 0 where id = p_image_id;
    insert into ords_log(priority, error_message)
                    values (9, 'Created image #' || p_image_id || ' in LiveLabs.');
exception
    when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message)
                        values (9, 'Error creating image #' || p_image_id || ' in LiveLabs: ' || errm);
    raise;
end;

procedure updateImage(p_image_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select json_object(
        'image_id'        value p_image_id,
         'listing_id'      value listing_id,
         'remarks'         value remarks,
         'seclist_req'     value seclist_req,
         'ocpu_req'        value ocpu_required,
         'image_req'       value image_req,
         'pubkey_req'      value pubkey_req,
         'novnc_enabled'   value novnc_enabled,
         'database_version' value database_version,
         'version'         value version,
         'instance_prefix' value instance_prefix,
         'image_ocid'      value image_ocid,
         'active_flg'      value 'Y'
         null on null
         returning clob
       )
    into   v_body
    from   omp_images
    where  id = p_image_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/updateImage/' || p_image_id,
                                            p_http_method => 'PUT',
                                            p_body => v_body,
                                            p_proxy_override => null);

    if apex_web_service.g_status_code != 200 then
    raise_application_error(
        -20001,
        'Sync REST call failed with status ' || apex_web_service.g_status_code
        || ': ' || substr(response, 1, 4000)
    );
    end if;
    dbms_output.put_line(response);

    update omp_images set updated_flg = 0 where id = p_image_id;
    insert into ords_log (priority, error_message)
    values (9, 'Updated image #' || p_image_id || ' in LiveLabs.');

exception when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message)
        values (9, 'Error updating image #' || p_image_id || ' in LiveLabs: ' || errm);
        raise;
end;

procedure deleteImage(p_image_id number) as
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS(p_content_type => null);
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';


    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/deleteImage/' || p_image_id,
                                            p_http_method => 'DELETE',
                                            p_proxy_override => null);
    dbms_output.put_line(response);
    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;
    insert into ords_log(priority, error_message)
                    values (9, 'Deleted image #' || p_image_id || ' in LiveLabs.');
exception
    when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message) values (9, 'Error deleting image #' || p_image_id || ' in LiveLabs: ' || errm);
        raise;
end;

procedure createImageConnection(p_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
    v_wms_id number;
    v_ll_id number;
    v_image_id number;
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';


    select json_object(
        'id' value p_id,
        'image_id' value image_id,
        'll_id'     value livelabs_id
         null on null
         returning clob
       ),
       image_id,
       livelabs_id
    into v_body,
         v_image_id,
         v_ll_id
    from wms_ll_images
    where id = p_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/createImageConnection',
                                            p_http_method => 'POST',
                                            p_body => v_body,
            p_proxy_override => null);
    dbms_output.put_line(response);
    if apex_web_service.g_status_code != 200 then
    raise_application_error(
        -20001,
        'Sync REST call failed with status ' || apex_web_service.g_status_code
        || ': ' || substr(response, 1, 4000)
    );
    end if;

    insert into ords_log (priority, error_message)
    values (9, 'Connected image #' || v_image_id || ' with LL ID #' || v_ll_id);

exception when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message, workshop_id, livelabs_id)
        values (9, 'Error connecting image #' || v_image_id || ' with LL ID #' || v_ll_id || ': ' || errm, (select workshop_id from workshop_ll where id = v_ll_id), v_ll_id);
        raise;
end;

procedure updateImageConnection(p_id number, p_image_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
    v_wms_id number;
    v_ll_id number;
    v_image_id number;
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select image_id into v_image_id from wms_ll_images where id = p_id;
    select livelabs_id into v_ll_id from wms_ll_images where id = p_id;
    select workshop_id into v_wms_id from workshop_ll where id = v_ll_id;

    select json_object(
        'new_image_id' value p_image_id,
        'old_image_id' value image_id,
        'll_id'     value livelabs_id
         null on null
         returning clob
       )
    into v_body
    from wms_ll_images
    where id = p_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/updateImageConnection',
                                            p_http_method => 'PUT',
                                            p_body => v_body,
            p_proxy_override => null);

    if apex_web_service.g_status_code != 200 then
    raise_application_error(
        -20001,
        'Sync REST call failed with status ' || apex_web_service.g_status_code
        || ': ' || substr(response, 1, 4000)
    );
    end if;

    update wms_ll_images set image_id = p_image_id where id = p_id;

    insert into ords_log (priority, error_message)
    values (9, 'Replaced image for LL ID #' || v_ll_id|| ' with image #' || p_image_id);

exception when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message, workshop_id, livelabs_id)
        values (9, 'Error updating image #' || p_image_id || ' in LiveLabs: ' || errm, v_wms_id, v_ll_id);
        raise;
end;

procedure deleteImageConnection(p_id number) as
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
    v_wms_id number;
    v_ll_id number;
    v_image_id number;
begin
    authorizeORDS(p_content_type => null);
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select image_id into v_image_id from wms_ll_images where id = p_id;
    select livelabs_id into v_ll_id from wms_ll_images where id = p_id;
    select workshop_id into v_wms_id from workshop_ll where id = v_ll_id;

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/deleteImageConnection/' || p_id,
                                            p_http_method => 'DELETE',
            p_proxy_override => null);
    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;

    delete from wms_ll_images where id = p_id;

    insert into ords_log(priority, error_message)
                    values (9, 'Deleted connection between image #' || v_image_id || ' and LL ID #' || v_ll_id);
exception when others then
    errm := SQLERRM;
    insert into ords_log(priority, error_message, workshop_id, livelabs_id)
                    values (9, 'Error deleting image connection #' || p_id|| ' in LiveLabs: ' || errm, v_wms_id, v_ll_id);
    raise;
end;

procedure createListing(p_listing_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select json_object(
         'listing_id'       value id,
         'listing_name'     value listing_name,
         'listing_ocid'    value listing_ocid,
         'added_by'         value added_by,
         'added_on'         value added_on,
         'app_catalog_ocid' value app_catalog_ocid,
         'support_contacts' value support_contacts
         null on null
         returning clob
       )
    into   v_body
    from   omp_listings
    where  id = p_listing_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/createListing',
                                            p_http_method => 'POST',
                                            p_body => v_body,
            p_proxy_override => null);
    dbms_output.put_line(response);
    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;

    insert into ords_log(priority, error_message)
                    values (9, 'Created listing #' || p_listing_id || ' in LiveLabs.');
exception when others then
    errm := SQLERRM;
    insert into ords_log(priority, error_message)
                    values (9, 'Error creating listing #' || p_listing_id || ' in LiveLabs: ' || errm);
    raise;

end;

procedure updateListing(p_listing_id number) as
    v_body clob;
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS;
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    select json_object(
         'listing_id'       value id,
         'listing_name'     value listing_name,
         'listing_ocid'    value listing_ocid,
         'added_by'         value added_by,
         'added_on'         value added_on,
         'app_catalog_ocid' value app_catalog_ocid,
         'support_contacts' value support_contacts
         null on null
         returning clob
       )
    into   v_body
    from   omp_listings
    where  id = p_listing_id;
    insert into ords_log(priority, error_message) values (9, 'JSON Payload: ' || v_body);

    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/updateListing/' || p_listing_id,
                                            p_http_method => 'PUT',
                                            p_body => v_body,
            p_proxy_override => null);
    dbms_output.put_line(response);
    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;

    insert into ords_log (priority, error_message)
    values (9, 'Updated listing #' || p_listing_id || ' in LiveLabs.');

exception when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message)
        values (9, 'Error updating listing #' || p_listing_id || ' in LiveLabs: ' || errm);
        raise;
end;

procedure deleteListing(p_listing_id number) as
    v_ords_url varchar2(1000);
    response clob;
    errm varchar2(4000);
begin
    authorizeORDS(p_content_type => null);
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';


    response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/deleteListing/' || p_listing_id,
                                            p_http_method => 'DELETE',
            p_proxy_override => null);
    dbms_output.put_line(response);
    if apex_web_service.g_status_code != 200 then
        raise_application_error(
            -20001,
            'Sync REST call failed with status ' || apex_web_service.g_status_code
            || ': ' || substr(response, 1, 4000)
        );
    end if;
    insert into ords_log(priority, error_message)
                    values (9, 'Deleted listing #' || p_listing_id || ' in LiveLabs.');
exception when others then
        errm := SQLERRM;
        insert into ords_log(priority, error_message)
                        values (9, 'Error deleting listing #' || p_listing_id || ' in LiveLabs: ' || errm);
        raise;
end;

    procedure pushImages as
        v_ords_url varchar2(4000);
        v_response clob;
        v_body clob;
        cursor c_updated_images is select *
                            from omp_images
                            where updated_flg > 0;
    begin
        authorizeORDS;
        select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';

        for image in c_updated_images loop
            if image.updated_flg = 1 then
                updateImage(image.id);
            elsif image.updated_flg = 2 then
                createImage(image.id);
            end if;
        end loop;

        insert into ords_log(priority, error_message)
        values (9, 'Compute images have been synced with LiveLabs.');
    end;

    function getImageConnections(p_image_id number) return varchar2 as
        v_response clob;
        v_connections varchar2(4000);
        v_ords_url varchar2(1000);
    begin
        select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
        v_response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/getImageConnections/' || p_image_id,
                                            p_http_method => 'GET',
                                            p_proxy_override => null);
        v_connections := JSON_VALUE(v_response, '$.connections');

        return v_connections;
    end;

    function getListingConnections(p_listing_id number) return varchar2 as
        v_response clob;
        v_connections varchar2(4000);
        v_ords_url varchar2(1000);
    begin
        select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
        v_response := apex_web_service.make_rest_request(p_url => v_ords_url || 'compute-images/getListingConnections/' || p_listing_id,
                                            p_http_method => 'GET',
                                            p_proxy_override => null);
        v_connections := JSON_VALUE(v_response, '$.connections');
        return v_connections;
    end;

    PROCEDURE updateAnalytics AS
        v_response    CLOB;
        v_ords_url    VARCHAR2(1000);
        v_status_code NUMBER;
        v_errm varchar2(4000);
    BEGIN
        authorizeORDS;

        SELECT value
          INTO v_ords_url
          FROM wms_system_parameters
         WHERE name = 'ORDS_URL';

        v_response := apex_web_service.make_rest_request(
            p_url             => v_ords_url || 'analytics/getAllAnalytics',
            p_http_method     => 'GET',
            p_proxy_override => null
        );

        v_status_code := apex_web_service.g_status_code;

        IF v_status_code != 200 THEN
            INSERT INTO ords_log(priority, error_message)
            VALUES (1, 'Analytics call failed. Status Code: ' || v_status_code || CHR(10) || v_response);
            RETURN;
        END IF;

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.total_page_views'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Total Page Views';

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.avg_monthly_page_views'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Average Monthly Page Views';

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.unique_visits'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Unique Visits';

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.events'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Events';

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.event_attendee_avg'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Average Event Attendees';

        UPDATE ll_analytics
           SET value = JSON_VALUE(v_response, '$.reservations_provisioned'),
               last_updated = SYSTIMESTAMP
         WHERE name = 'Reservations Provisioned';

        INSERT INTO ords_log(priority, error_message)
        VALUES (9, 'Updated statistics received:' || CHR(10) || v_response);

    EXCEPTION
        WHEN OTHERS THEN
        v_errm := SQLERRM;
            INSERT INTO ords_log(priority, error_message)
            VALUES (1, 'updateAnalytics failed: ' || v_errm);
            RAISE;
    END;


    procedure updateLiveLabsInfo(p_ll_id number) as
    v_ords_url varchar2(4000);
    v_clob clob;
    v_flg varchar2(1);
    v_views number;
    begin
    -- get base ORDS url
    select value into v_ords_url from wms_system_parameters where name = 'ORDS_URL';
    -- fetch workshop in LL
    begin
        v_clob := apex_web_service.make_rest_request( p_url => v_ords_url || 'workshops/read/getWorkshop/' || p_ll_id,
                                                    p_http_method => 'GET',
                                                    p_proxy_override => null );
        v_views := nvl(json_value(v_clob, '$.pg_views'), 0);
        select workshop_json into v_clob from json_table(v_clob, '$' columns (workshop_json));
        select LiveLabsGreenEnabled into v_flg from json_table(v_clob, '$' columns (LiveLabsGreenEnabled));
    exception
        when others then
            v_flg := 'N';
            v_views := 0;
    end;
    merge into livelabs_sandbox_enabled sand
        using (select p_ll_id as id, v_flg as flg, v_views as page_views from dual) rest
        on (sand.livelabs_id = rest.id)
    when matched then
        update set sandbox_flg = rest.flg, page_views = rest.page_views, last_updated = sysdate
    when not matched then
        insert (livelabs_id, sandbox_flg, page_views, last_updated)
        values (rest.id, rest.flg, rest.page_views, sysdate);
    end;

    procedure updateLiveLabsInfoAll as
    begin
        authorizeORDS;
        FOR rec IN (SELECT DISTINCT id FROM workshop_ll where updated_publish_flg < 2) LOOP
            updateLiveLabsInfo(rec.id);
        end loop;
    end;

        procedure createAsset(
        p_asset_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'id'           value id,
             'name'         value name,
             'active_flg'   value active_flg,
             'url'          value link,
             'created_on'   value created_on,
             'type_id'      value type_id
             null on null
             returning clob
           )
        into v_body
        from wms_assets
        where id = p_asset_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/asset',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Created asset #' || p_asset_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating asset #' || p_asset_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateAsset(
        p_asset_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'name'         value name,
             'active_flg'   value active_flg,
             'url'          value link,
             'type_id'      value type_id,
             'created_on'   value created_on,
             'updated_on'   value updated_on
             null on null
             returning clob
           )
        into v_body
        from wms_assets
        where id = p_asset_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/asset/' || p_asset_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Updated asset #' || p_asset_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating asset #' || p_asset_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteAsset(
        p_asset_id number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/asset/' || p_asset_id,
                        p_http_method => 'DELETE',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Deleted asset #' || p_asset_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting asset #' || p_asset_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure createAssetType(
        p_type_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'id'                value id,
             'name'              value name,
             'icon_class'        value icon_class,
             'background_color'   value background_color
             null on null
             returning clob
           )
        into v_body
        from wms_asset_types
        where id = p_type_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/type',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create asset type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Created asset type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating asset type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateAssetType(
        p_type_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'name'              value name,
             'icon_class'        value icon_class,
             'background_color'   value background_color
             null on null
             returning clob
           )
        into v_body
        from wms_asset_types
        where id = p_type_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/type/' || p_type_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update asset type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Updated asset type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating asset type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteAssetType(
        p_type_id number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'assets/type/' || p_type_id,
                        p_http_method => 'DELETE',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete asset type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Deleted asset type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting asset type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

procedure createLiveStack(
        p_livestack_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'id'              value id,
             'name'            value name,
             'active_flg'      value active_flg,
             'desc_short'      value desc_short,
             'desc_long'       value desc_long,
             'outline'         value outline,
             'prereqs'         value prereqs,
             'video_link'      value video_link,
             'length_override' value length_override,
             'livestack_type'  value livestack_type,
             'created_date'    value to_char(created_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             'featured_flg'    value featured_flg
             null on null
             returning clob
           )
        into v_body
        from wms_livestacks
        where id = p_livestack_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create LiveStack REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Created LiveStack #' || p_livestack_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating LiveStack #' || p_livestack_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateLiveStack(
        p_livestack_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'name'            value name,
             'active_flg'      value active_flg,
             'desc_short'      value desc_short,
             'desc_long'       value desc_long,
             'outline'         value outline,
             'prereqs'         value prereqs,
             'video_link'      value video_link,
             'length_override' value length_override,
             'livestack_type'  value livestack_type,
             'created_date'    value to_char(created_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             'featured_flg'    value featured_flg
             null on null
             returning clob
           )
        into v_body
        from wms_livestacks
        where id = p_livestack_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack/' || p_livestack_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update LiveStack REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Updated LiveStack #' || p_livestack_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating LiveStack #' || p_livestack_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteLiveStack(
        p_livestack_id number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack/' || p_livestack_id,
                        p_http_method => 'DELETE',
                        p_body => '{}',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete LiveStack REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Deleted LiveStack #' || p_livestack_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting LiveStack #' || p_livestack_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure createLiveStackAsset(
        p_livestack_id number,
        p_asset_id     number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'livestack_id' value livestack_id,
             'asset_id'     value asset_id,
             'external_flg' value external_flg,
             'position'     value position
             null on null
             returning clob
           )
        into v_body
        from wms_livestack_assets
        where livestack_id = p_livestack_id
          and asset_id = p_asset_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-asset',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create LiveStack asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (
            9,
            'Created LiveStack asset for LiveStack #' || p_livestack_id ||
            ', asset #' || p_asset_id || ' in LiveLabs.'
        );

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating LiveStack asset for LiveStack #' || p_livestack_id ||
                ', asset #' || p_asset_id || ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateLiveStackAsset(
        p_livestack_id number,
        p_asset_id     number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'external_flg' value external_flg,
             'position'     value position
             null on null
             returning clob
           )
        into v_body
        from wms_livestack_assets
        where livestack_id = p_livestack_id
          and asset_id = p_asset_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-asset/' ||
                                 p_livestack_id || '/' || p_asset_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update LiveStack asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (
            9,
            'Updated LiveStack asset for LiveStack #' || p_livestack_id ||
            ', asset #' || p_asset_id || ' in LiveLabs.'
        );

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating LiveStack asset for LiveStack #' || p_livestack_id ||
                ', asset #' || p_asset_id || ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteLiveStackAsset(
        p_livestack_id number,
        p_asset_id     number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-asset/' ||
                                 p_livestack_id || '/' || p_asset_id,
                        p_http_method => 'DELETE',
                        p_body => '{}',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete LiveStack asset REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (
            9,
            'Deleted LiveStack asset for LiveStack #' || p_livestack_id ||
            ', asset #' || p_asset_id || ' in LiveLabs.'
        );

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting LiveStack asset for LiveStack #' || p_livestack_id ||
                ', asset #' || p_asset_id || ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure createLiveStackEntry(
        p_entry_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'id'                    value id,
             'livestack_id'          value livestack_id,
             'entry_id'              value entry_id,
             'position'              value position,
             'title_override'        value title_override,
             'desc_short_override'   value desc_short_override,
             'length_hours_override' value length_hours_override,
             'active_flg'            value active_flg,
             'entry_type'            value entry_type,
             'royt_override_flg'     value royt_override_flg,
             'ros_override_flg'      value ros_override_flg
             null on null
             returning clob
           )
        into v_body
        from wms_livestack_entries
        where id = p_entry_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-entry',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create LiveStack entry REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Created LiveStack entry #' || p_entry_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating LiveStack entry #' || p_entry_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateLiveStackEntry(
        p_entry_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'livestack_id'          value livestack_id,
             'entry_id'              value entry_id,
             'position'              value position,
             'title_override'        value title_override,
             'desc_short_override'   value desc_short_override,
             'length_hours_override' value length_hours_override,
             'active_flg'            value active_flg,
             'entry_type'            value entry_type,
             'royt_override_flg'     value royt_override_flg,
             'ros_override_flg'      value ros_override_flg
             null on null
             returning clob
           )
        into v_body
        from wms_livestack_entries
        where id = p_entry_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-entry/' || p_entry_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update LiveStack entry REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Updated LiveStack entry #' || p_entry_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating LiveStack entry #' || p_entry_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteLiveStackEntry(
        p_entry_id number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'livestacks/livestack-entry/' || p_entry_id,
                        p_http_method => 'DELETE',
                        p_body => '{}',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete LiveStack entry REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Deleted LiveStack entry #' || p_entry_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting LiveStack entry #' || p_entry_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

procedure createLLType(
        p_type_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'id'   value id,
             'name' value name
             null on null
             returning clob
           )
        into v_body
        from wms_ll_types
        where id = p_type_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'type',
                        p_http_method => 'POST',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 201 then
            raise_application_error(
                -20001,
                'Create LL type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Created LL type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error creating LL type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure updateLLType(
        p_type_id number
    ) as
        v_body       clob;
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS;

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        select json_object(
             'name' value name
             null on null
             returning clob
           )
        into v_body
        from wms_ll_types
        where id = p_type_id;

        insert into ords_log(priority, error_message)
        values (9, 'JSON Payload: ' || v_body);

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'type/' || p_type_id,
                        p_http_method => 'PUT',
                        p_body => v_body,
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Update LL type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Updated LL type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error updating LL type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

    procedure deleteLLType(
        p_type_id number
    ) as
        v_ords_url   varchar2(1000);
        response     clob;
        errm         varchar2(4000);
    begin
        authorizeORDS(p_content_type => null);

        select value
          into v_ords_url
          from wms_system_parameters
         where name = 'ORDS_URL';

        response := apex_web_service.make_rest_request(
                        p_url => v_ords_url || 'type/' || p_type_id,
                        p_http_method => 'DELETE',
                        p_body => '{}',
                        p_proxy_override => null);

        dbms_output.put_line(response);

        if apex_web_service.g_status_code != 200 then
            raise_application_error(
                -20001,
                'Delete LL type REST call failed with status ' ||
                apex_web_service.g_status_code || ': ' ||
                substr(response, 1, 4000)
            );
        end if;

        insert into ords_log(priority, error_message)
        values (9, 'Deleted LL type #' || p_type_id || ' in LiveLabs.');

    exception
        when others then
            errm := SQLERRM;

            insert into ords_log(priority, error_message)
            values (
                9,
                'Error deleting LL type #' || p_type_id ||
                ' in LiveLabs: ' || errm
            );

            raise;
    end;

end;
/