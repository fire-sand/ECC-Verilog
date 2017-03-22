/* LC5 Test Configuration
 * Aasif Versi and Satya Bodduluri
 * Mar 2017
 */


`define CODE_PATH "/home/aasif/Documents/School/2017a/SrDesign/RSA-CPU/src/test_data/"
//`define CODE_PATH "/home/satya/School/ese450/RSA-CPU_private/lc4/"


//`define TEST_CASE "test_ecc"
//`define TEST_CASE "mult"
//`define TEST_CASE "mod"
//`define TEST_CASE "point_add"
`define TEST_CASE "mod_carry"

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
