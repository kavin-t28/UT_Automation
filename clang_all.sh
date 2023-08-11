#!/bin/bash

FILES+=(src/common/*.c)
FILES+=(src/common/*/*.c)
FILES+=(src/pcb/*/*.c)
FILES+=(cmocka/wrap/*.c)
FILES+=(cmocka/wrap/common/*/*.c)
FILES+=(cmocka/src/common/*.c)
FILES+=(cmocka/src/common/*/*.c)

./clang.sh ${FILES[@]}

