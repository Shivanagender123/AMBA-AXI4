class slave_xtn extends uvm_sequence_item;
	`uvm_object_utils(slave_xtn)
	
////////////////////////////////write addr channel/////////////////////////

bit [3:0]awid;
bit [31:0]awaddr;
bit [3:0]awlen;
bit [2:0]awsize;
bit [1:0]awburst;
bit awvalid;
bit awready;

//////////////////////////////////write_data_channel/////////////////////////
bit [3:0]wid;
bit [31:0]wdata[$];
bit [3:0]wstrb[$];
bit wlast;
bit wvalid;
bit wready;

///////////////////////////////////write response channel////////////////////

bit [3:0]bid;
bit [1:0]bresp;
bit bvalid;
bit bready;

////////////////////////////////////read addr channel////////////////////////

bit [3:0]arid;
bit [31:0]araddr;
bit [3:0]arlen;
bit [2:0]arsize;
bit [1:0]arburst;
bit arvalid;
bit arready;

/////////////////////////////////////read data/response channel///////////////

bit [3:0]rid;
bit [31:0]rdata[$];
bit [1:0]rresp;
bit rlast;
bit rvalid;
bit rready;
/////////////////////////////////////////////////////////////////////
rand int awready_delay;
rand int wready_delay;
rand int arready_delay;
rand int bvalid_delay;
rand int rvalid_delay;
////////////////////////////////////////////////////////////////////

constraint DELAY      {awready_delay<5;wready_delay<5;bvalid_delay<5;arready_delay<5;rvalid_delay<5;}

function void do_print(uvm_printer printer);
	super.do_print(printer);
printer.print_field("AWID",this.awid,4,UVM_DEC);
	printer.print_field("AWADDR",this.awaddr,32,UVM_DEC);
	printer.print_field("AWLEN",this.awlen,4,UVM_DEC);
	printer.print_field("AWSIZE",this.awsize,3,UVM_DEC);
	printer.print_field("AWBURST",this.awburst,2,UVM_DEC);
	printer.print_field("WID",this.wid,4,UVM_DEC);
	foreach(wdata[i])
		printer.print_field($sformatf("WDATA[%0d]",i),this.wdata[i],32,UVM_DEC);
	foreach(rdata[i])
		printer.print_field($sformatf("RDATA[%0d]",i),this.rdata[i],32,UVM_DEC);
	printer.print_field("BID",this.bid,4,UVM_DEC);
	printer.print_field("BRESP",this.bresp,2,UVM_DEC);
	printer.print_field("ARID",this.arid,4,UVM_DEC);
	printer.print_field("ARADDR",this.araddr,32,UVM_DEC);
	printer.print_field("ARLEN",this.arlen,4,UVM_DEC);
	printer.print_field("ARSIZE",this.arsize,3,UVM_DEC);
	printer.print_field("ARBURST",this.arburst,2,UVM_DEC);
endfunction
endclass
