class master_monitor extends uvm_monitor;

`uvm_component_utils(master_monitor)

uvm_analysis_port #(master_xtn) monitor_port_3;
uvm_analysis_port #(master_xtn) monitor_port_1;
uvm_analysis_port #(master_xtn) monitor_port_2;
uvm_analysis_port #(master_xtn) monitor_port_4;
uvm_analysis_port #(master_xtn) monitor_port_5;
 master_agent_config m_cfg;
  master_xtn xtn_1;
  master_xtn xtn_2;
  master_xtn xtn_3;
  master_xtn xtn_4;
  master_xtn xtn_5;
    
	semaphore write_addr_channel;
	semaphore write_data_channel;
	semaphore write_resp_channel;
	semaphore read_addr_channel;
	semaphore read_data_channel;

virtual axi_if.MMON_MP vif;

int wd,rd;

static int b;

extern function new(string name = "master_monitor",uvm_component parent);
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

function master_monitor:: new(string name="master_monitor",uvm_component parent);
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

/////////////////////////////////////////////BUILD_PHASE//////////////////////////////////////////////////////////////////////////////////
function void master_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
                if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
endfunction

//////////////////////////////////CONNECT_PHASE////////////////////////////////////////////////////////////
function void master_monitor::connect_phase(uvm_phase phase);
vif=m_cfg.vif;
endfunction         
///////////////////////////////////RUN PHASE///////////////////////////////////////////

task master_monitor::run_phase(uvm_phase phase);
		forever collect_data;
endtask

///////////////////////////////////COLLECT DATA/////////////////////////////////////////////////

task master_monitor::collect_data;
	fork
		begin
		write_addr_channel.get(1);
		write_addr();
		write_addr_channel.put(1);
                 //  b++;
                  // $display("%d master monitor ",b);
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

task master_monitor::write_addr;
	xtn_1=master_xtn::type_id::create("xtn_1");
	@(vif.mmon_cb)
	wait(vif.mmon_cb.awvalid)
	xtn_1.awaddr=vif.mmon_cb.awaddr;
	xtn_1.awlen=vif.mmon_cb.awlen;
	xtn_1.awsize=vif.mmon_cb.awsize;
	xtn_1.awburst=vif.mmon_cb.awburst;
	xtn_1.awid=vif.mmon_cb.awid;
	wait(vif.mmon_cb.awready)
	monitor_port_1.write(xtn_1);
	@(vif.mmon_cb)
	xtn_1.print;
endtask

////////////////////////////////////////////WRITE_DATA_CHANNEL///////////////////////////////////////

task master_monitor::write_data;
	wd=1;
	xtn_2=master_xtn::type_id::create("xtn_2");
	@(vif.mmon_cb)
	while(wd)
	begin
	@(vif.mmon_cb);
	wait(vif.mmon_cb.wvalid)
	xtn_2.wdata.push_back(vif.mmon_cb.wdata);
	wait(vif.mmon_cb.wready)
	@(vif.mmon_cb);
	if(vif.mmon_cb.wlast)
	wd=0;
	end
	monitor_port_2.write(xtn_2);
	xtn_2.print;	
endtask

////////////////////////////////////////////WRITE_RESP_CHANNEL//////////////////////////////////////

task master_monitor::write_resp;
	xtn_3=master_xtn::type_id::create("xtn_3");
	@(vif.mmon_cb)
	wait(vif.mmon_cb.bvalid&&vif.mmon_cb.bready)
	xtn_3.bid=vif.mmon_cb.bid;
	xtn_3.bresp=vif.mmon_cb.bresp;
	@(vif.mmon_cb);
	monitor_port_3.write(xtn_1);
endtask

////////////////////////////////////////////READ_ADDR_CHANNEL////////////////////////////////////////


task master_monitor::read_addr;
	xtn_4=master_xtn::type_id::create("xtn_4");
	@(vif.mmon_cb)
	wait(vif.mmon_cb.arvalid)
	xtn_4.araddr=vif.mmon_cb.araddr;
	xtn_4.arlen=vif.mmon_cb.arlen;
	xtn_4.arsize=vif.mmon_cb.arsize;
	xtn_4.arburst=vif.mmon_cb.arburst;
	xtn_4.arid=vif.mmon_cb.arid;
	wait(vif.mmon_cb.arready)
	monitor_port_4.write(xtn_4);
	@(vif.mmon_cb);
endtask

///////////////////////////////////////////////READ_DATA_CHANNEL//////////////////////////////////////

task master_monitor::read_data;
	rd=1;
	xtn_5=master_xtn::type_id::create("xtn_5");
	@(vif.mmon_cb)
	while(rd)
	begin
	@(vif.mmon_cb);
	wait(vif.mmon_cb.rvalid&&vif.mmon_cb.rready)
	xtn_5.rdata.push_back(vif.mmon_cb.rdata);
	@(vif.mmon_cb);
	if(vif.mmon_cb.rlast)
	rd=0;
	end
	monitor_port_5.write(xtn_5);	
endtask

///////////////////////////////////////////////////////////////////////////////////////////////////////
	
