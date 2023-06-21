CONSUL_SVC=$(systemctl status consul | grep 'Active:' | awk -F': ' '{$1=""; print $0}' | awk -F';' '{print $1}' | xargs)
NOMAD_SVC=$(systemctl status nomad | grep 'Active:' | awk -F': ' '{$1=""; print $0}' | awk -F';' '{print $1}' | xargs)

echo -e "===== SERVICES ===============================================================
 $COLOR_COLUMN- consul$RESET_COLORS.............: $COLOR_VALUE ${CONSUL_SVC}$RESET_COLORS
 $COLOR_COLUMN- nomad (server)$RESET_COLORS.....: $COLOR_VALUE ${NOMAD_SVC}$RESET_COLORS"
