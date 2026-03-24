create or replace PACKAGE BODY "LL_PKG_AI" AS

    -- -------------------------------------------------------------------------
    -- Returns a VECTOR embedding for the given text using the configured
    -- APEX Vector Provider (multilingual_e5_small_model).
    -- -------------------------------------------------------------------------
    FUNCTION get_embedding (p_text IN clob) RETURN VECTOR IS
    BEGIN
        RETURN apex_ai.get_vector_embeddings(
            p_value             => p_text,
            p_service_static_id => 'multilingual_e5_small_model'
        );
    END get_embedding;
   

    FUNCTION get_search_embedding (p_text IN clob) RETURN VECTOR IS
        v_clean clob;
    BEGIN
        -- remove non-alphanumeric and non-dash characters 
        v_clean := REGEXP_REPLACE(p_text, '[^A-Za-z0-9 -]', ' ');
        -- make multiple dashes into 1 dash
        v_clean := REGEXP_REPLACE(v_clean, '-{2,}', '-');
        -- remove multiple whitespace for single whitespace
        v_clean := trim(REGEXP_REPLACE(v_clean, '\s+', ' '));
        -- substr to at most 200 chars
        v_clean := substr(v_clean, 1, 200);
        RETURN apex_ai.get_vector_embeddings(
            p_value             => v_clean,
            p_service_static_id => 'multilingual_e5_small_model'
        );
    END get_search_embedding;

    FUNCTION get_workshop_embedding (p_name IN varchar2, p_desc_short IN varchar2, p_desc_long IN varchar2) RETURN VECTOR IS
        v_clob clob;
    BEGIN
        v_clob := 'Title: '             || nvl(p_name, 'N/A')         || CHR(10) ||
                  'Short Description: ' || nvl(p_desc_short, 'N/A')   || CHR(10) ||
                  'Long Description: '  || NVL(p_desc_long, 'N/A')    || CHR(10);
        RETURN apex_ai.get_vector_embeddings(
            p_value             =>  v_clob,
            p_service_static_id => 'multilingual_e5_small_model'
        );
    END get_workshop_embedding;

    -- -------------------------------------------------------------------------
    -- Calls the OCI GenAI Llama 3.3 service to generate a natural language
    -- answer grounded in the provided workshop context (RAG).
    -- -------------------------------------------------------------------------
    FUNCTION ai_search_response (
        p_query   IN VARCHAR2,
        p_context IN CLOB
    ) RETURN CLOB IS

        l_system_prompt VARCHAR2(4000) :=
            'You are a helpful assistant for Oracle LiveLabs, a free workshop platform. ' ||
            'A user has submitted a search query and you have been provided with the most ' ||
            'semantically relevant workshops and sprints from the catalog. ' ||

            'Workshops are in-depth, multi-step learning experiences typically lasting 1 or more hours. ' ||
            'Sprints are short, focused guides that answer a single specific question or task. ' ||

            'Your job is to: ' ||
            '1. Briefly answer or acknowledge the user''s intent in 1-2 sentences. ' ||
            '2. Recommend the most appropriate content from what you have been given, ' ||
            '   prioritizing Workshops for broad or learning-focused queries and Sprints for ' ||
            '   specific how-to questions. Explain why each recommendation fits the user''s needs. ' ||
            '3. Keep your response concise, friendly, and focused on the content given. ' ||
            'Do not invent workshops or details that are not in the provided context. ' ||
            'If none of the provided content is a good match, say so honestly. ' ||

            'Your response should be in HTML format. Do not add any CSS styling, but use div, span, or p tags as needed. ' ||

            'Anytime you reference a workshop or sprint, you should hyperlink it with HTML. ' ||
            'The context will provide the title and ID. ' ||
            'Use the ID like how you see it in the link below for example ID 1234: ' ||
            'https://livelabs.oracle.com/ords/r/dbpm/livelabs/view-workshop?wid=1234 ' ||
            'Do not include the workshop ID in displayed text as a part of the HTML. Only use the ID in the links. ' ||

            'You are a response on a search page, so act as if speaking to the user in second person. ' ||
            'If the query is broad or conceptual, focus your recommendation on Workshops over Sprints. ' ||
            'If the query is a specific task or how-to question, Sprints may be the best answer. ' ||
            'If both types are relevant, recommend the most useful ones from each. ' ||
            'If there are additional relevant results beyond those you mention, note that more workshops and sprints are available in the other region below.';

        l_user_prompt CLOB;

    BEGIN
        l_user_prompt :=
            'User Query: ' || p_query                             || CHR(10) ||
            CHR(10)                                                            ||
            'Relevant Workshops from the LiveLabs Catalog:'       || CHR(10) ||
            p_context                                             || CHR(10) ||
            CHR(10)                                                            ||
            'Please provide a helpful response based only on the workshops above.';

        RETURN apex_ai.generate(
            p_prompt             => l_user_prompt,
            p_system_prompt      => l_system_prompt,
            p_service_static_id  => 'oci_genai_llama3_3_william',
            p_temperature        => 0.3
        );

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'AI response unavailable at this time. Please use the keyword search below.';
    END ai_search_response;


    -- -------------------------------------------------------------------------
    -- Main entry point: embeds the query, runs vector similarity search against
    -- the workshops table, builds RAG context, and returns the AI answer plus
    -- the ordered list of matching workshop IDs.
    --
    -- NOTE: Adjust the table name, vector column, and context columns below
    --       to match your actual workshops table schema.
    -- -------------------------------------------------------------------------
    PROCEDURE search_workshops_ai (
        p_query        IN  VARCHAR2,
        p_ai_answer    OUT CLOB,
        p_workshop_ids OUT SYS.ODCINUMBERLIST
    ) IS

        c_top_k        CONSTANT PLS_INTEGER := 6;

        l_query_vector VECTOR;
        l_context      CLOB := '';

    BEGIN
        p_workshop_ids := SYS.ODCINUMBERLIST();

        -- 1. Embed the user query using the configured vector provider
        l_query_vector := get_search_embedding(p_query);

        -- 2. Vector similarity search — update table/column names as needed
        FOR rec IN (
            SELECT
                w.id,
                w.name,
                w.desc_long,
                w.desc_short,
                CASE WHEN nvl(json_value(w.workshop_json, '$.SprintEnabled'), 'N') = 'Y' THEN 'Sprint' ELSE 'Workshop' END AS workshop_type,
                MIN(VECTOR_DISTANCE(v.embedding, l_query_vector, COSINE)) AS distance
            FROM
                william_test_prod_workshops w
                LEFT JOIN WILLIAM_TEST_WORKSHOP_VECTORS v ON v.workshop_id = w.id
            WHERE
                v.embedding IS NOT NULL
                AND w.active_flg = 'Y'
            GROUP BY
                w.id,
                w.name,
                w.desc_long,
                w.desc_short,
                workshop_type
            ORDER BY distance ASC
            FETCH FIRST c_top_k ROWS ONLY
        ) LOOP
            -- Collect workshop IDs in ranked order
            p_workshop_ids.EXTEND;
            p_workshop_ids(p_workshop_ids.COUNT) := rec.id;

            -- Build RAG context block for this workshop
            l_context := l_context
                || 'Title: '             || rec.name                     || CHR(10)
                || 'Type: '              || rec.workshop_type            || CHR(10)
                || 'Workshop ID'         || rec.id                       || CHR(10)
                || 'Short Description: ' || nvl(rec.desc_short, 'N/A')   || CHR(10)
                || 'Long Description: '  || NVL(rec.desc_long, 'N/A')    || CHR(10)
                || '---'                                                 || CHR(10);
        END LOOP;

        -- 3. Generate the AI answer using the retrieved context
        IF p_workshop_ids.COUNT > 0 THEN
            p_ai_answer := ai_search_response(
                p_query   => p_query,
                p_context => l_context
            );
        ELSE
            p_ai_answer := 'No workshops were found matching your query. '
                        || 'Try different keywords or browse the catalog below.';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_ai_answer    := 'An error occurred during AI search: ' || SQLERRM;
            p_workshop_ids := SYS.ODCINUMBERLIST();
    END search_workshops_ai;



    FUNCTION format_ctx_query(p_query IN VARCHAR2) RETURN VARCHAR2 IS
    l_words   APEX_T_VARCHAR2;
    l_result  VARCHAR2(4000) := '';
    l_clean   VARCHAR2(4000);
    BEGIN
        IF p_query IS NULL OR TRIM(p_query) IS NULL THEN
            RETURN NULL;
        END IF;

        -- Strip Oracle Text special characters first
        l_clean := REGEXP_REPLACE(p_query, '[&|!();,\-]', ' ');
        l_words  := APEX_STRING.SPLIT(TRIM(l_clean), ' ');

        -- wrap each word in brackets to make search fuzzy 
        FOR i IN 1..l_words.COUNT LOOP
            IF TRIM(l_words(i)) IS NOT NULL THEN
                l_result := l_result
                            || CASE WHEN l_result IS NOT NULL THEN ' OR ' END
                            || '{' || TRIM(l_words(i)) || '}';
            END IF;
        END LOOP;
        if l_result = '' then
            return null;
        else
            RETURN l_result;
        end if;
    END format_ctx_query;



    FUNCTION BUILD_WORKSHOP_CLOB(
        p_name       IN VARCHAR2,
        p_desc_short IN VARCHAR2,
        p_desc_long  IN VARCHAR2
    ) RETURN CLOB AS
        v_result CLOB := '';
    BEGIN
        v_result := v_result || 'Title: '             || NVL(p_name,       'N/A') || CHR(10);
        v_result := v_result || 'Short Description: ' || NVL(p_desc_short, 'N/A') || CHR(10);
        v_result := v_result || 'Long Description: '  || NVL(p_desc_long,  'N/A') || CHR(10);
        RETURN v_result;
    END BUILD_WORKSHOP_CLOB;




    FUNCTION CHUNK_TEXT(
        p_content   IN CLOB,
        p_max_words IN NUMBER DEFAULT 300,
        p_overlap   IN NUMBER DEFAULT 25
    ) RETURN VECTOR_ARRAY_T AS
        v_chunk_params VARCHAR2(500);
    BEGIN
        v_chunk_params := JSON_OBJECT(
            'by'        VALUE 'words',
            'max'       VALUE TO_CHAR(p_max_words),
            'overlap'   VALUE TO_CHAR(p_overlap),
            'split'     VALUE 'sentence',
            'language'  VALUE 'american',
            'normalize' VALUE 'all'
        );

        RETURN DBMS_VECTOR.UTL_TO_CHUNKS(
            DATA   => p_content,
            PARAMS => json(v_chunk_params)
        );
    END CHUNK_TEXT;
    


    FUNCTION VECTORIZE_CHUNKS(
        p_chunks IN VECTOR_ARRAY_T,
        p_model  IN VARCHAR2 DEFAULT NULL
    ) RETURN VECTOR_ARRAY_T AS
        v_params VARCHAR2(200);
        v_model varchar2(4000);
    BEGIN
        if p_model is null then 
            v_model := ll_pkg_admin.system_parameter('DATABASE_EMBEDDING_MODEL');
        else
            v_model := p_model;
        end if;
        v_params := JSON_OBJECT('provider' VALUE 'database', 'model' VALUE v_model);

        RETURN DBMS_VECTOR.UTL_TO_EMBEDDINGS(
            DATA   => p_chunks,
            PARAMS => json(v_params)
        );
    END VECTORIZE_CHUNKS;
    


    PROCEDURE VECTORIZE_WORKSHOP(
        p_workshop_id IN NUMBER,
        p_name        IN VARCHAR2,
        p_desc_short  IN VARCHAR2,
        p_desc_long   IN VARCHAR2,
        p_model       IN VARCHAR2 DEFAULT NULL,
        p_max_words   IN NUMBER   DEFAULT 300,
        p_overlap     IN NUMBER   DEFAULT 25
    ) AS
        v_combined   CLOB;
        v_chunks     VECTOR_ARRAY_T;
        v_embeddings VECTOR_ARRAY_T;
        v_chunk_json CLOB;
        v_embed_json CLOB;
        v_chunk_text VARCHAR2(4000);
        v_chunk_id   NUMBER;
        v_embedding  VECTOR;
        v_model      varchar2(4000);
    BEGIN
        if p_model is null then 
            v_model := ll_pkg_admin.system_parameter('DATABASE_EMBEDDING_MODEL');
        else
            v_model := p_model;
        end if;
        -- Step 1: Build the combined CLOB
        v_combined := BUILD_WORKSHOP_CLOB(p_name, p_desc_short, p_desc_long);

        -- Step 2: Chunk the CLOB
        v_chunks := CHUNK_TEXT(v_combined, p_max_words, p_overlap);

        -- Step 3: Vectorize all chunks in one batch call
        v_embeddings := VECTORIZE_CHUNKS(v_chunks, v_model);

        -- Step 4: Delete existing vectors for this workshop
        DELETE FROM WILLIAM_TEST_WORKSHOP_VECTORS WHERE workshop_id = p_workshop_id;

        -- Step 5: Insert chunk text + embedding together
        -- v_chunks and v_embeddings are parallel arrays indexed by chunk_id
        FOR i IN 1 .. v_chunks.COUNT LOOP
            v_chunk_json := v_chunks(i);
            v_embed_json := v_embeddings(i);

            SELECT JSON_VALUE(v_chunk_json, '$.chunk_id'      RETURNING NUMBER),
                   JSON_VALUE(v_chunk_json, '$.chunk_data'    RETURNING VARCHAR2(4000))
            INTO v_chunk_id, v_chunk_text
            FROM DUAL;

            -- embed_vector is a CLOB in the embeddings array output
            SELECT TO_VECTOR(JSON_VALUE(v_embed_json, '$.embed_vector' RETURNING CLOB))
            INTO v_embedding
            FROM DUAL;

            INSERT INTO WILLIAM_TEST_WORKSHOP_VECTORS (workshop_id, chunk_index, chunk_text, embedding)
            VALUES (p_workshop_id, v_chunk_id, v_chunk_text, v_embedding);
        END LOOP;

    END VECTORIZE_WORKSHOP;
    

    

END "LL_PKG_AI";
/