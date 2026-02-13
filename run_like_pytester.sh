#!/bin/bash
set -e

# dir of this script
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MM=$MAMBA_EXE
WASM_PREFIX_DIR=$THIS_DIR/debug_prefix
EMSCRIPTEN_VERSION_CONSTRAINT="==4.0.9"
HOST_WORK_DIR=$THIS_DIR/host_work_dir_py
HOST_MOUNT_DIR=$THIS_DIR/mount_dir



# create the wasm prefix if it does not exist
if [ -d "$WASM_PREFIX_DIR" ]; then
    echo "WASM prefix $WASM_PREFIX_DIR already exists, skipping creation"
else
    rm -rf $WASM_PREFIX_DIR
    echo "Creating wasm env at $WASM_PREFIX_DIR"
    $MM create -p $WASM_PREFIX_DIR \
        --platform=emscripten-wasm32 \
        -c https://repo.prefix.dev/emscripten-forge-4x \
        -c https://repo.prefix.dev/conda-forge \
        --yes \
        python "emscripten-abi$EMSCRIPTEN_VERSION_CONSTRAINT"\
        numpy scipy pydantic-core pyjs pytest
fi


mkdir -p $HOST_WORK_DIR
cd $HOST_WORK_DIR
export WASM_PREFIX=$WASM_PREFIX_DIR
python $THIS_DIR/pytester_alike.py