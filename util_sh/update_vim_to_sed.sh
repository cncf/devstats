#!/bin/bash
# echo "vim --not-a-term -c '%s/\"Grafana - \"/\"CNCF DevStats - \"/g' -c 'wq"'!'"' \"\$f\"" | sed "s|vim --not-a-term -c '%s/\"Grafana - \"/\"\(.*\) DevStats - \"/g' -c 'wq"'!'"' \"\\\$f\"|sed -i 's\|\"Grafana - \"\|\"\1 DevStats - \"\|g'|g"
# want to hit:
# vim --not-a-term -c "%s/'Grafana - '/'CNCF DevStats - '/g" -c 'wq!' "$f"
# vim --not-a-term -c '%s/"Grafana - "/"CNCF DevStats - "/g' -c 'wq!' "$f"
# vim --not-a-term -c "%s/' - Grafana'/' - CNCF DevStats'/g" -c 'wq!' "$f"
# vim --not-a-term -c '%s/" - Grafana"/" - CNCF DevStats"/g' -c 'wq!' "$f"
# cp ./grafana/cncf/change_title_and_icons.sh ./input.sh
for f in $(find . -iname "change_title_and_icons.sh")
do
  echo "$f"
  sed -i "s|vim --not-a-term -c \"%s/'Grafana - '/'\(.*\) DevStats - '/g\" -c 'wq"'!'"' \"\\\$f\"|sed -i \"s\|'Grafana - '\|'\1 DevStats - '\|g\" \"\\\$f\"|g" "$f"
  sed -i "s|vim --not-a-term -c '%s/\"Grafana - \"/\"\(.*\) DevStats - \"/g' -c 'wq"'!'"' \"\\\$f\"|sed -i 's\|\"Grafana - \"\|\"\1 DevStats - \"\|g' \"\\\$f\"|g" "$f"
  sed -i "s|vim --not-a-term -c \"%s/' - Grafana'/' - \(.*\) DevStats'/g\" -c 'wq"'!'"' \"\\\$f\"|sed -i \"s\|' - Grafana'\|' - \1 DevStats'\|g\" \"\\\$f\"|g" "$f"
  sed -i "s|vim --not-a-term -c '%s/\" - Grafana\"/\" - \(.*\) DevStats\"/g' -c 'wq"'!'"' \"\\\$f\"|sed -i 's\|\" - Grafana\"\|\" - \1 DevStats\"\|g' \"\\\$f\"|g" "$f"
done
