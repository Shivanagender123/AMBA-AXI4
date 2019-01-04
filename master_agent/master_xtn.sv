class master_xtn extends uvm_sequence_item;
	`uvm_object_utils(master_xtn)
	
////////////////////////////////write addr channel/////////////////////////

rand bit [3:0]awid;
rand bit [31:0]awaddr;
rand bit [3:0]awlen;

rand bit [31:0]next_addr[];

rand bit [2:0]awsize;
rand bit [1:0]awburst;
bit awvalid;
bit awready;

//////////////////////////////////write_data_channel/////////////////////////
rand bit [3:0]wid;
rand bit [31:0]wdata[$];

rand bit [31:0]wdata_temp[];

rand bit [3:0]wstrb[];
rand bit wlast;
bit wvalid;
bit wready;

///////////////////////////////////write response channel////////////////////

rand bit [3:0]bid;
bit [1:0]bresp;
bit bvalid;
bit bready;

////////////////////////////////////read addr channel////////////////////////

rand bit [3:0]arid;
rand bit [31:0]araddr;
rand bit [3:0]arlen;
rand bit [2:0]arsize;
rand bit [1:0]arburst;
bit arvalid;
bit arready;

/////////////////////////////////////read data/response channel///////////////

rand bit [3:0]rid;
bit [31:0]rdata[$];
bit [1:0]rresp;
bit rlast;
bit rvalid;
bit rready;

//////////////////////////////////////////////////////////////////////////////

rand  int ex;
rand int delay;

//////////////////////////////////////////////////////////////////////////////

int lower_byte_lane,upper_byte_lane;
int x,y,z;
int p,q;
int alligned_addr,alligned_addr_temp;
int wrap_boundary;
int no_of_lanes=4;
rand int awvalid_delay;
rand int wvalid_delay;
rand int arvalid_delay;
rand int bready_delay;
rand int rready_delay;

////////////////////////////////////////constraints////////////////////////////

constraint ID         {awid==wid && awid==bid;}

constraint SIZE	      {awsize inside {0,1,2};}

constraint BURST_TYPE {awburst!=3;}

constraint ARRAY_SIZE {wdata.size==awlen+1;wstrb.size==awlen+1;next_addr.size==awlen+1;}

constraint DELAY      {delay<=30;delay>0;}

constraint EX	      {if(awburst==2) awlen+1==2**ex ;}	

constraint WRAP       {ex inside {[1:4]};}

constraint AW 	      {awaddr<2000;}

constraint FIXED      {if(awburst==0) awaddr%(2**awsize)==0;}

constraint DELAY1      {awvalid_delay<5;wvalid_delay<5;bready_delay<5;arvalid_delay<5;rready_delay<5;}

///////////////////////////////////////////////////////////////////////////////

function void post_randomize();

//////////////////////addr calculation/////////////////////////////////////////

x=(awaddr/(2**awsize));
alligned_addr= (x * (2**awsize));

if(awburst==1)
	begin
		next_addr[0]=awaddr;
			for(int j=1;j<awlen+1;j++)
				begin
						next_addr[j]=alligned_addr+((j-0)*(2**awsize));
				end
	end
if(awburst==0)
	begin
		for(int j=0;j<awlen+1;j++)
			next_addr[j]=awaddr;
	end

if(awburst==2)
	begin
	awaddr=alligned_addr;
	alligned_addr_temp=awaddr;
	z=2;
	next_addr[0]=awaddr;
	y=(awaddr/(2**awsize)*(awlen+1));
	wrap_boundary=y*((2**awsize)*(awlen+1));
		for(int j=1;j<awlen+1;j++)
			begin		
				next_addr[j]=alligned_addr_temp+((z-1)*(2**awsize));
				z+=1;
				if(next_addr[j]==wrap_boundary+((2**awsize)*(awlen+1)))
				begin
					alligned_addr_temp=wrap_boundary;
					z=1;
				end
	
			end
	end
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////strobe claculation/////////////////////////////////
foreach(wstrb[i])
begin
wstrb[i]=0;
if(awburst==0)
	begin
	for(int j=0;j<(2**awsize);j++)
		wstrb[i][j]=1;
	end
else if(i==0)
	begin
	p=(awaddr/no_of_lanes);
	lower_byte_lane=next_addr[i]-(p* no_of_lanes);
	upper_byte_lane=alligned_addr+(2**awsize -1)-(p * no_of_lanes);
	for(int l=lower_byte_lane;l<upper_byte_lane+1;l++)
		wstrb[i][l]=1;
	end
	
else
	begin
	q=next_addr[i]/no_of_lanes ;
	lower_byte_lane=next_addr[i]-(q*no_of_lanes);
	upper_byte_lane=lower_byte_lane+(2**awsize-1);
	for(int l=lower_byte_lane;l<upper_byte_lane+1;l++)
		wstrb[i][l]=1;
	end
end

//////////////////////////////////////////////////////////////////////////////////////

endfunction

extern function void do_print(uvm_printer printer);

//extern function void do_compare(uvm_component rhs,uvm_comparer comparer);
endclass

function void master_xtn::do_print(uvm_printer printer);

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
	foreach(wstrb[i])	
		printer.print_field($sformatf("WSTRB[%0d]",i),this.wstrb[i],4,UVM_BIN);	
	foreach(next_addr[i])	
		printer.print_field($sformatf("NEXT_ADDR[%0d]",i),this.next_addr[i],4,UVM_DEC);	
if(awburst==2) begin
		printer.print_field("wrap_boundary",this.wrap_boundary,32,UVM_DEC);
		printer.print_field("limit",this.wrap_boundary+((2**awsize)*(awlen+1)),32,UVM_DEC);
		end
	printer.print_field("BID",this.bid,4,UVM_DEC);
	printer.print_field("BRESP",this.bresp,2,UVM_DEC);
	printer.print_field("ARID",this.arid,4,UVM_DEC);
	printer.print_field("ARADDR",this.araddr,32,UVM_DEC);
	printer.print_field("ARLEN",this.arlen,4,UVM_DEC);
	printer.print_field("ARSIZE",this.arsize,3,UVM_DEC);
	printer.print_field("ARBURST",this.arburst,2,UVM_DEC);
endfunction
