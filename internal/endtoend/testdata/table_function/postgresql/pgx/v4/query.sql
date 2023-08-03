/* name: GetTransaction :many */
SELECT
	jsonb_extract_path(transactions.data, '$.transaction.signatures[0]'),
	jsonb_agg(instructions.value)
FROM
  transactions, 
	jsonb_each(jsonb_extract_path(transactions.data, '$.transaction.message.instructions[0]')) AS instructions
WHERE
	transactions.program_id = sqlc.arg('program_id')
	AND jsonb_extract_path(transactions.data, '$.transaction.signatures[0]') @> to_jsonb(sqlc.arg('data')::text)
	AND jsonb_extract_path(jsonb_extract_path(transactions.data, '$.transaction.message.accountKeys'), 'key') = to_jsonb(transactions.program_id)
GROUP BY transactions.id;

/* name: GetTransactionWithoutAlias :many */
SELECT
    json_extract(transactions.data, '$.transaction.signatures[0]'),
    json_group_array(value)
FROM
    transactions,
    json_each(json_extract(transactions.data, '$.transaction.message.instructions'))
WHERE
    transactions.program_id = $1
    AND json_extract(transactions.data, '$.transaction.signatures[0]') > $2
    AND json_extract(json_extract(transactions.data, '$.transaction.message.accountKeys'), '$[' || json_extract(value, '$.programIdIndex') || ']') = transactions.program_id
GROUP BY transactions.id
LIMIT $3;
