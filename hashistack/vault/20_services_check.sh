VAULT_SVC=$(systemctl status vault | grep 'Active:' | awk -F': ' '{$1=""; print $0}' | awk -F';' '{print $1}' | xargs)

echo -e "===== SERVICES ===============================================================
 $COLOR_COLUMN- vault $RESET_COLORS.............: $COLOR_VALUE ${VAULT_SVC}$RESET_COLORS"
