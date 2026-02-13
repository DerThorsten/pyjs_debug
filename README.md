# Why?

On emscripten-forg 4x, we see issues in the ci when testing certain packages.
In particular: 
  - scipy
  - pydantic-core

are known to cause issues. 
It is unclear if this is a problem with the packages themselves, pyjs, or the testing with playwright.


To investigate this, we test this here in two ways:
    - run a simple script to import the packages via playwright in the browser
    - run a simple script to import the packages as ordenary webpage


Install empack and pyjs_code_runner and run:
    - `./setup_webpage.sh` to setup the webpage (see index.html), the script will also start a server and open the webpage in the browser
    - `./run_via_playwright.sh` to run the script in `mount_dir/main.py` via playwright