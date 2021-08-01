FILE_CMD="$HOME/.local/bin/file"

$FILE_CMD resholver
"$FILE_CMD" resholver
${FILE_CMD} resholver
"${FILE_CMD}" resholver
${FILE_CMD:-default} resholver
"${FILE_CMD:-default}" resholver
exec $FILE_CMD
exec "$FILE_CMD"
exec $FILE_CMD | exec $FILE_CMD
exec "$FILE_CMD" | exec "$FILE_CMD"
