class slave_monitor extends uvm_monitor;

`uvm_component_utils(slave_monitor)

uvm_analysis_port #(slave_xtn) monitor_port_3;
uvm_analysis_port #(slave_xtn) monitor_port_1;
uvm_analysis_port #(slave_xtn) monitor_port_2;
uvm_analysis_port #(slave_xtn) monitor_port_4;
uvm_analysis_port #(slave_xtn) monitor_port_5;
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

virtual axi_if.SMON_MP vif;

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
	monitor_port_1=new("monitor_port_1",this);
	monitor_port_2=new("monitor_port_2",this);
	monitor_port_3=new("monitor_port_3",this);
	monitor_port_4=new("monitor_port_4",this);
	monitor_port_5=new("monitor_port_5",this);
	write_addr_channel=new(1);
  	write_data_channel=new(1);
  	write_resp_channel=new(1);
  	read_addr_channel=new(1);
  	read_data_channel=new(1);
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
		end

		begin
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
	xtn_1=slave_xtn::type_id::create("xtn_1");
	@(vif.smon_cb)
	wait(vif.smon_cb.awvalid&&vif.smon_cb.awready)
	xtn_1.awaddr=vif.smon_cb.awaddr;
	xtn_1.awlen=vif.smon_cb.awlen;
	xtn_1.awsize=vif.smon_cb.awsize;
	xtn_1.awburst=vif.smon_cb.awburst;
	xtn_1.awid=vif.smon_cb.awid;
	monitor_port_1.write(xtn_1);
	@(vif.smon_cb);
endtask

////////////////////////////////////////////WRITE_DATA_CHANNEL///////////////////////////////////////

task slave_monitor::write_data;
	wd=1;
	xtn_2=slave_xtn::type_id::create("xtn_2");
	@(vif.smon_cb)
	while(wd)
	begin
	@(vif.smon_cb)
	wait(vif.smon_cb.wvalid&&vif.smon_cb.wready)
	@(vif.smon_cb);
	xtn_2.wdata.push_back(vif.smon_cb.wdata);
	if(vif.smon_cb.wlast)
	wd=0;
	end
	monitor_port_2.write(xtn_2);	
endtask

////////////////////////////////////////////WRITE_RESP_CHANNEL//////////////////////////////////////

task slave_monitor::write_resp;
	xtn_3=slave_xtn::type_id::create("xtn_3");
	@(vif.smon_cb)
	wait(vif.smon_cb.bvalid)
	xtn_3.bid=vif.smon_cb.bid;
	xtn_3.bresp=vif.smon_cb.bresp;
	wait(vif.smon_cb.bready)
	@(vif.smon_cb)
	monitor_port_3.write(xtn_1);
endtask

////////////////////////////////////////////READ_ADDR_CHANNEL////////////////////////////////////////


task slave_monitor::read_addr;
	xtn_4=slave_xtn::type_id::create("xtn_4");
	@(vif.smon_cb)
	wait(vif.smon_cb.arvalid&&vif.smon_cb.arready)
	xtn_4.araddr=vif.smon_cb.araddr;
	xtn_4.arlen=vif.smon_cb.arlen;
	xtn_4.arsize=vif.smon_cb.arsize;
	xtn_4.arburst=vif.smon_cb.arburst;
	xtn_4.arid=vif.smon_cb.arid;
	monitor_port_4.write(xtn_4);
	@(vif.smon_cb);
endtask

///////////////////////////////////////////////READ_DATA_CHANNEL//////////////////////////////////////

task slave_monitor::read_data;
	rd=1;
	xtn_5=slave_xtn::type_id::create("xtn_5");
	@(vif.smon_cb)
	while(rd)
	begin
	@(vif.smon_cb)
	wait(vif.smon_cb.rvalid)
	xtn_5.rdata.push_back(vif.smon_cb.rdata);
	wait(vif.smon_cb.rready)
	@(vif.smon_cb);
	if(vif.smon_cb.rlast)
	rd=0;
	end
	monitor_port_5.write(xtn_5);	
endtask

///////////////////////////////////////////////////////////////////////////////////////////////////////
	
