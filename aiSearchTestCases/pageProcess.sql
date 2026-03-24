DECLARE
    v_workshop_ids SYS.ODCINUMBERLIST;
    v_ids_csv VARCHAR2(4000) := '';
    v_answer CLOB;
BEGIN
    -- Clear previous results first
    :P100_AI_WORKSHOPS := NULL;
    :P100_AI_ANSWER := NULL;

    ll_pkg_ai.search_workshops_ai(
        p_query        => :SEARCH,
        p_ai_answer    => v_answer,
        p_workshop_ids => v_workshop_ids
    );

    :P100_AI_ANSWER := v_answer;

    IF v_workshop_ids IS NOT NULL AND v_workshop_ids.COUNT > 0 THEN
        FOR i IN 1..v_workshop_ids.COUNT LOOP
            v_ids_csv := v_ids_csv ||
                         CASE WHEN i > 1 THEN ',' END ||
                         v_workshop_ids(i);
        END LOOP;
    END IF;

    :P100_AI_WORKSHOPS := v_ids_csv;
END;