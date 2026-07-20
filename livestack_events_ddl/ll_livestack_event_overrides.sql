alter table ll_livestack_events add (
    title_override      varchar2(1000),
    desc_long_override  varchar2(4000),
    outline_override    varchar2(4000),
    prereqs_override    varchar2(4000)
);

comment on column ll_livestack_events.title_override is
    'Optional LiveStack title override for this event.';
comment on column ll_livestack_events.desc_long_override is
    'Optional LiveStack long description override for this event.';
comment on column ll_livestack_events.outline_override is
    'Optional LiveStack outline override for this event.';
comment on column ll_livestack_events.prereqs_override is
    'Optional LiveStack prerequisites override for this event.';
