module top;
import test_pkg::*;
import uvm_pkg::*;
bit clk;

always #5 clk=~clk;
//master_xtn xtn;
axi_if in(clk);

initial
 begin
//	xtn=new;
//	assert(xtn.randomize);
//	xtn.print;
	uvm_config_db #(virtual axi_if)::set(null,"*","vif_0",in);
	run_test;
 end

endmodule
