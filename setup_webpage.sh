#!/bin/bash
set -e

# dir of this script
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MM=$MAMBA_EXE
WASM_PREFIX_DIR=$THIS_DIR/debug_prefix
EMSCRIPTEN_VERSION_CONSTRAINT="==4.0.9"
DEPLOYMENT_DIR=$THIS_DIR/deploy



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


# pack env with empack
mkdir -p $DEPLOYMENT_DIR
if true; then

    cd $THIS_DIR

    empack pack env \
        --env-prefix $WASM_PREFIX_DIR \
        --relocate-prefix "/" \
        --no-use-cache \
        --outdir  $DEPLOYMENT_DIR 

fi

# copy index.html to deployment dir
cp $THIS_DIR/index.html $DEPLOYMENT_DIR/index.html

# copy pyjs to deployment dir
cp -r $WASM_PREFIX_DIR/lib_js/pyjs/* $DEPLOYMENT_DIR


# find free port and start a simple http server in the deployment dir as background process
cd $DEPLOYMENT_DIR
PORT=8000
while lsof -i:$PORT >/dev/null; do
    PORT=$((PORT+1))
done

# open browser as background task (but wait one 1 second to give the server time to start)
if which xdg-open > /dev/null; then
    (sleep 1 && xdg-open http://localhost:$PORT) &
elif which open > /dev/null; then
    (sleep 1 && open http://localhost:$PORT) &
else
    echo "Could not detect web browser to open, please open http://localhost:$PORT in your browser"
fi  

echo "Starting http server at http://localhost:$PORT"
python -m http.server $PORT 

