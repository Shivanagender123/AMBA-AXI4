package test_pkg;


//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv
	`include "uvm_macros.svh"

`include "master_xtn.sv"
`include "master_agent_config.sv"
`include "slave_agent_config.sv"
`include "env_config.sv"
`include "master_driver.sv"
`include "master_monitors.sv"
`include "master_sequencer.sv"
`include "master_agent.sv"
`include "master_agent_top.sv"
`include "master_seq.sv"

`include "slave_xtn.sv"
`include "slave_driver.sv"
`include "slave_monitors.sv"
`include "slave_sequencer.sv"
`include "slave_agent.sv"
`include "slave_agent_top.sv"
`include "slave_seq.sv"

`include "virtual_sequencer.sv"
`include "virtual_seq.sv"
`include "scoreboards.sv"

`include "tb.sv"


`include "test.sv"
endpackage
