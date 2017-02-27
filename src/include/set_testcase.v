/* LC4 Datapath Test Configuration
 * Benedict Brown
 * Februrary 2015
 */

/* Path to the test files, relative to the simulation directory.
 * If Vivado can't find the files, replace this with an absolute path.
 * Windows users probably need to use "/" instead of "\" as the directory separator.
 */
`define CODE_PATH "/home/aasif/Documents/School/2017a/SrDesign/RSA-CPU/src/test_data/"
//`define CODE_PATH "/home/satya/School/ese450/RSA-CPU_private/lc4/"

/* Uncomment one of the lines below to specify the test case
 * You will need to restart the behavioral simulation
 * but you do not need to re-synthesize or re-implement.
 *
 * All test cases should pass before you attempt to program the Zedboard.
 *
 * When you do program the zeboard, hook it up to a VGA monitor, and try
 * the house and wireframe tests.  Switch SW0 turns the display output on and off.
 *
 * On the wireframe test, use the +-shaped button pad diagonally opposite the power
 * port to rotate the wireframe on the display.
 */

// `define TEST_CASE "test_alu"
//`define TEST_CASE "test_add"
//`define TEST_CASE "test_br"
// `define TEST_CASE "test_ld_br"
// `define TEST_CASE "test_all"
// `define TEST_CASE "house"
// `define TEST_CASE "wireframe"
`define TEST_CASE "ours"

/* DO NOT MODIFY ANYTHING BELOW THIS LINE */

/* Define the full paths to the trace, output, and hex files.
 * INPUT_FILE and OUTPUT_FILE are used by the testbench,
 * MEMORY_IMAGE_FILE is used by bram.v.
 */
`define INPUT_FILE        { `CODE_PATH, `TEST_CASE, ".trace"  }
`define OUTPUT_FILE       { `CODE_PATH, `TEST_CASE, ".output" }
`define MEMORY_IMAGE_FILE { `CODE_PATH, `TEST_CASE, ".hex"    }
`define REG_IMAGE_FILE   { `CODE_PATH, `TEST_CASE, ".reg.hex"    }

/* Define the full paths the the register file tests.
 * These are read by test_lc4_regfile.tf.
 */
`define REGISTER_INPUT    { `CODE_PATH, "test_lc4_regfile.input" }
`define REGISTER_OUTPUT   { `CODE_PATH, "test_lc4_regfile.output" }
