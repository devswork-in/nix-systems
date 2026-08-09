function kai --description "Run KAI from the source checkout"
    command direnv exec /home/creator54/kai/core env PYTHONPATH=/home/creator54/kai/core /home/creator54/.venv/bin/python3 -m core.cli $argv
end
