#!/bin/bash

rm -rf *.{hex,obj,trace}

echo Running script to generate test trace and hex files...

java -enableassertions -jar PennSim.jar -t -s test.script
