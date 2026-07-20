declare
    l_table_exists          number;
    l_title_override_exists number;
    l_event_title_exists    number;
begin
    select count(*)
      into l_table_exists
      from user_tables
     where table_name = 'LL_LIVESTACK_EVENTS';

    if l_table_exists = 0 then
        return;
    end if;

    select count(*)
      into l_title_override_exists
      from user_tab_cols
     where table_name = 'LL_LIVESTACK_EVENTS'
       and column_name = 'TITLE_OVERRIDE';

    select count(*)
      into l_event_title_exists
      from user_tab_cols
     where table_name = 'LL_LIVESTACK_EVENTS'
       and column_name = 'EVENT_TITLE';

    if l_title_override_exists = 1 and l_event_title_exists = 0 then
        execute immediate 'alter table ll_livestack_events rename column title_override to event_title';
    elsif l_title_override_exists = 1 and l_event_title_exists = 1 then
        execute immediate 'update ll_livestack_events set event_title = title_override where event_title is null and title_override is not null';
        execute immediate 'alter table ll_livestack_events drop column title_override';
    elsif l_title_override_exists = 0 and l_event_title_exists = 0 then
        execute immediate 'alter table ll_livestack_events add event_title varchar2(1000)';
    end if;
end;
/

comment on column ll_livestack_events.event_title is
    'Event title shown for this LiveStack event.';
