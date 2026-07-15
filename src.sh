#!/bin/bash
# dump_repo.py --remove-include-ext '.json;.txt;.sh;.yaml;.md'
dump_repo.py --remove-include-ext '.json;.txt;' --add-exclude-glob '*/*/*vars.yaml;*/grafana/*/*.sh'
