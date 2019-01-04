class slave_monitor extends uvm_monitor;

`uvm_component_utils(slave_monitor)

uvm_analysis_port #(slave_xtn) monitor_port_r;
uvm_analysis_port #(slave_xtn) monitor_port_w;
 slave_agent_config m_cfg;

  slave_xtn xtn_1;
  slave_xtn xtn_2;
  slave_xtn xtn_3;
  slave_xtn xtn_4;
  slave_xtn xtn_5;

int wd,rd;

	semaphore write_addr_channel;
	semaphore write_data_channel;
	semaphore write_resp_channel;
	semaphore read_addr_channel;
	semaphore read_data_channel;
	semaphore w;
virtual axi_if.SMON_MP vif;

int awid[$];
int awaddr[$];

int arid[$];
int araddr[$];

slave_xtn wr_xtn[int][int];
slave_xtn rd_xtn[int][int];

int bid[$];
int baddr[$];


extern function new(string name = "slave_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
//extern function void report_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task collect_data();
extern task run_phase(uvm_phase phase);
extern task write_addr();
extern task write_data();
extern task write_resp();
extern task read_addr();
extern task read_data();

endclass
///////////////////////////////////////////////NEW_CONSTRUCTOR///////////////////////////////////////////////////////////////////////////

function slave_monitor:: new(string name="slave_monitor",uvm_component parent);
     super.new(name,parent);
	monitor_port_r=new("monitor_port_r",this);
	monitor_port_w=new("monitor_port_w",this);
	write_addr_channel=new(1);
  	write_data_channel=new(1);
  	write_resp_channel=new(1);
  	read_addr_channel=new(1);
  	read_data_channel=new(1);
	w=new(0);
endfunction

/////////////////////////////////////////////BUILD_PHASE////////////////////////////////////////////////////////////////////

function void slave_monitor::build_phase(uvm_phase phase);
 super.build_phase(phase);
                if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
        endfunction
//////////////////////////////////CONNECT_PHASE////////////////////////////////////////////////////////////

function void slave_monitor::connect_phase(uvm_phase phase);
vif=m_cfg.vif;
endfunction     

////////////////////////////////////RUN_PHASE///////////////////////////////////////////////

task slave_monitor::run_phase(uvm_phase phase);
			forever collect_data;
endtask

///////////////////////////////////COLLECT DATA/////////////////////////////////////////////////

task slave_monitor::collect_data;
	fork
		begin
		write_addr_channel.get(1);
		write_addr();
		write_addr_channel.put(1);
		w.put(1);
		end

		begin
		w.get(1);
		write_data_channel.get(1);
		write_data();
		write_data_channel.put(1);
		write_resp_channel.put(1);
		end

		begin
		write_resp_channel.get(2);
		write_resp();
		write_resp_channel.put(1);
		end

		begin
		read_addr_channel.get(1);
		read_addr();
		read_addr_channel.put(1);
		read_data_channel.put(1);
		end

		begin
		read_data_channel.get(2);
		read_data();
		read_data_channel.put(1);
		end
	join_any
endtask

////////////////////////////////////////////WRITE_ADRR_CHANNEL//////////////////////////////////////////

task slave_monitor::write_addr;
int awid_1;
int awaddr_1;
	@(vif.smon_cb)
	wait(vif.smon_cb.awvalid&&vif.smon_cb.awready)
	awid_1=vif.smon_cb.awid;
	awaddr_1=vif.smon_cb.awaddr;
	wr_xtn[awid_1][awaddr_1]=slave_xtn::type_id::create($sformatf("slave wr_xtn[%0d][%0d]",vif.smon_cb.awid,vif.smon_cb.awaddr));
	wr_xtn[awid_1][awaddr_1].awaddr=vif.smon_cb.awaddr;
	wr_xtn[awid_1][awaddr_1].awid=vif.smon_cb.awid;
	wr_xtn[awid_1][awaddr_1].awlen=vif.smon_cb.awlen;
	wr_xtn[awid_1][awaddr_1].awsize=vif.smon_cb.awsize;
	wr_xtn[awid_1][awaddr_1].awburst=vif.smon_cb.awburst;
	awaddr.push_front(awaddr_1);
	awid.push_front(awid_1);
	bid.push_front(awid_1);
	baddr.push_front(awaddr_1);
	@(vif.smon_cb);
endtask

////////////////////////////////////////////WRITE_DATA_CHANNEL///////////////////////////////////////

task slave_monitor::write_data;
int awaddr_2;
int awid_2;
	wd=1;
	awaddr_2=awaddr.pop_back;
	awid_2=awid.pop_back;
	@(vif.smon_cb)
	for(int i=0;i<wr_xtn[awid_2][awaddr_2].awlen+1;i++)
	begin
	@(vif.smon_cb);
	wait(vif.smon_cb.wvalid&&vif.smon_cb.wready);
	wr_xtn[awid_2][awaddr_2].wdata.push_front(vif.smon_cb.wdata);
	@(vif.smon_cb);
	end

endtask

////////////////////////////////////////////WRITE_RESP_CHANNEL//////////////////////////////////////

task slave_monitor::write_resp;
int awaddr_3;
int in[$];
int b;
	@(vif.smon_cb)
	wait(vif.smon_cb.bvalid)
	b=vif.smon_cb.bid;
	in=bid.find_last_index with(item==b);
	awaddr_3=baddr[in[0]];
	bid.delete(in[0]);
	baddr.delete(in[0]);
	in.delete;
	wr_xtn[b][awaddr_3].bid=vif.smon_cb.bid;
	wr_xtn[b][awaddr_3].bresp=vif.smon_cb.bresp;
	wait(vif.smon_cb.bready)
	@(vif.smon_cb);
	wr_xtn[b][awaddr_3].print;
	monitor_port_w.write(wr_xtn[b][awaddr_3]);
endtask

////////////////////////////////////////////READ_ADDR_CHANNEL////////////////////////////////////////


task slave_monitor::read_addr;
int arid_1;
int araddr_1;
	@(vif.smon_cb)
	wait(vif.smon_cb.arvalid&&vif.smon_cb.arready)
	arid_1=vif.smon_cb.arid;
	araddr_1=vif.smon_cb.araddr;
	rd_xtn[arid_1][araddr_1]=slave_xtn::type_id::create($sformatf("slave rd_xtn[%0d][%0d]",vif.smon_cb.arid,vif.smon_cb.araddr));
	rd_xtn[arid_1][araddr_1].araddr=vif.smon_cb.araddr;
	rd_xtn[arid_1][araddr_1].arlen=vif.smon_cb.arlen;
	rd_xtn[arid_1][araddr_1].arid=vif.smon_cb.arid;
	rd_xtn[arid_1][araddr_1].arsize=vif.smon_cb.arsize;
	rd_xtn[arid_1][araddr_1].arburst=vif.smon_cb.arburst;
	araddr.push_front(araddr_1);
	arid.push_front(arid_1);
	@(vif.smon_cb);

endtask

///////////////////////////////////////////////READ_DATA_CHANNEL//////////////////////////////////////

task slave_monitor::read_data;
int araddr_2;
int arid_2;
	wd=1;
	araddr_2=araddr.pop_back;
	arid_2=arid.pop_back;
	@(vif.smon_cb)
	for(int i=0;i<rd_xtn[arid_2][araddr_2].arlen+1;i++)
	begin
	@(vif.smon_cb);
	wait(vif.smon_cb.rvalid)
	rd_xtn[arid_2][araddr_2].rdata.push_front(vif.smon_cb.rdata);
	rd_xtn[arid_2][araddr_2].rresp=vif.smon_cb.rresp;
	wait(vif.smon_cb.rready)
	@(vif.smon_cb);
	end
	rd_xtn[arid_2][araddr_2].print;
	monitor_port_r.write(rd_xtn[arid_2][araddr_2]);
endtask

///////////////////////////////////////////////////////////////////////////////////////////////////////
	
