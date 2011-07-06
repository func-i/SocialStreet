CREATE TYPE tp_concat AS (data TEXT[], delimiter TEXT);

CREATE OR REPLACE FUNCTION group_concat_iterate(_state tp_concat, _value TEXT, delimiter TEXT, is_distinct boolean)
  RETURNS tp_concat AS
$BODY$
  SELECT
    CASE
      WHEN $1 IS NULL THEN ARRAY[$2]
      WHEN $4 AND $1.data @> ARRAY[$2] THEN $1.data
      ELSE $1.data || $2
  END,
  $3
$BODY$
  LANGUAGE 'sql' VOLATILE;

CREATE OR REPLACE FUNCTION group_concat_finish(_state tp_concat)
  RETURNS text AS
$BODY$
    SELECT array_to_string($1.data, $1.delimiter)
$BODY$
  LANGUAGE 'sql' VOLATILE;

CREATE AGGREGATE group_concat(text, text, boolean) (SFUNC = group_concat_iterate, STYPE = tp_concat, FINALFUNC = group_concat_finish);