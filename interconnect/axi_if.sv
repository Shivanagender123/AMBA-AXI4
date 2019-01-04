interface axi_if (input  clk);
logic [3:0]awid;
logic [31:0]awaddr;
logic [3:0]awlen;
logic [2:0]awsize;
logic [1:0]awburst;
logic awlock;
logic awcache;
logic awprot;
logic awqos;
logic awregion;
logic awuser;
logic awvalid;
logic awready;

logic [3:0]wid;
logic [31:0]wdata;
logic [3:0]wstrb;
logic wlast;
logic wuser;
logic wvalid;
logic wready;

logic [3:0]bid;
logic [1:0]bresp;
logic buser;
logic bvalid;
logic bready;

logic [3:0]arid;
logic [31:0]araddr;
logic [3:0]arlen;
logic [2:0]arsize;
logic [1:0]arburst;
logic arlock;
logic arcache;
logic arprot;
logic arqos;
logic arregion;
logic aruser;
logic arvalid;
logic arready;

logic [3:0]rid;
logic [31:0]rdata;
logic [3:0]rresp;
logic rlast;
logic ruser;
logic rvalid;
logic rready;

logic csysreq;
logic csysack;
logic cactive;
////////////////////////////////////////////////MASTER_DRIVER/////////////////////////////////////////
clocking mdr_cb @(posedge clk);
output awid;
output awaddr;
output awlen;
output awsize;
output awburst;
output awlock;
output awcache;
output awprot;
output awqos;
output awregion;
output awuser;
output awvalid;
input awready;

output wid;
output wdata;
output wstrb;
output wlast;
output wuser;
output wvalid;
input wready;

input bid;
input bresp;
input buser;
input bvalid;
output bready;

output arid;
output araddr;
output arlen;
output arsize;
output arburst;
output arlock;
output arcache;
output arprot;
output arqos;
output arregion;
output aruser;
output arvalid;
input arready;

input rid;
input rdata;
input rresp;
input rlast;
input ruser;
input rvalid;
output rready;

endclocking

////////////////////////////////////////////////////////////////MASTER_MONITOR////////////////////////////////////////////''''''''''
clocking mmon_cb @(posedge clk);
input awid;
input awaddr;
input awlen;
input awsize;
input awburst;
input awlock;
input awcache;
input awprot;
input awqos;
input awregion;
input awuser;
input awvalid;
input awready;

input wid;
input wdata;
input wstrb;
input wlast;
input wuser;
input wvalid;
input wready;

input bid;
input bresp;
input buser;
input bvalid;
input bready;

input arid;
input araddr;
input arlen;
input arsize;
input arburst;
input arlock;
input arcache;
input arprot;
input arqos;
input arregion;
input aruser;
input arvalid;
input arready;

input rid;
input rdata;
input rresp;
input ruser;
input rlast;
input rvalid;
input rready;

endclocking
/////////////////////////////////////////////////////////////////////SLAVE_DRIVER///////////////////////////////////////////////////////////////
clocking sdr_cb @(posedge clk);
input awid;
input awaddr;
input awlen;
input awsize;
input awburst;
input awlock;
input awcache;
input awprot;
input awqos;
input awregion;
input awuser;
input awvalid;
output awready;

input wid;
input wdata;
input wstrb;
input wlast;
input wuser;
input wvalid;
output wready;

output bid;
output bresp;
output buser;
output bvalid;
input bready;

input arid;
input araddr;
input arlen;
input arsize;
input arburst;
input arlock;
input arcache;
input arprot;
input arqos;
input arregion;
input aruser;
input arvalid;
output arready;

output rid;
output rdata;
output rresp;
output ruser;
output rlast;
output rvalid;
input rready;

endclocking
/////////////////////////////////////////////////////////////SLAVE_MONITOR/////////////////////////////////////////
clocking smon_cb @(posedge clk);
input awid;
input awaddr;
input awlen;
input awsize;
input awburst;
input awlock;
input awcache;
input awprot;
input awqos;
input awregion;
input awuser;
input awvalid;
input awready;

input wid;
input wdata;
input wstrb;
input wlast;
input wuser;
input wvalid;
input wready;

input bid;
input bresp;
input buser;
input bvalid;
input bready;

input arid;
input araddr;
input arlen;
input arsize;
input arburst;
input arlock;
input arcache;
input arprot;
input arqos;
input arregion;
input aruser;
input arvalid;
input arready;

input rid;
input rdata;
input rresp;
input rlast;
input ruser;
input rvalid;
input rready;

endclocking

/////////////////////////////////////////////////////////////////////MOD PORTS//////////////////////////////////////////////////////////////////

modport MDR_MP(clocking mdr_cb);
modport MMON_MP(clocking mmon_cb);
modport SDR_MP(clocking sdr_cb);
modport SMON_MP(clocking smon_cb);


endinterface
