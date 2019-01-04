class master_driver extends uvm_driver#(master_xtn) ;

`uvm_component_utils(master_driver)
virtual axi_if.MDR_MP vif;
master_agent_config m_cfg;

static int a;

	semaphore write_addr_channel;
	semaphore write_data_channel;
	semaphore write_resp_channel;
	semaphore read_addr_channel;
	semaphore read_data_channel;

	master_xtn q1[$];
	master_xtn q2[$];
	master_xtn q3[$];
	master_xtn q4[$];
	master_xtn q5[$];

extern function new(string name="master_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
  extern task send_to_dut(master_xtn xtn);
 extern task run_phase(uvm_phase phase);
extern task write_addr(master_xtn xtn);
extern task write_data(master_xtn xtn);
extern task write_resp(master_xtn xtn);
extern task read_addr(master_xtn xtn);
extern task read_data(master_xtn xtn);

endclass
//////////////////////////////////////CONSTUCTOR/////////////////////////////////////////////////
function master_driver::new(string name="master_driver",uvm_component parent);
  super.new(name,parent);
  	write_addr_channel=new(1);
  	write_data_channel=new(1);
  	write_resp_channel=new(1);
  	read_addr_channel=new(1);
  	read_data_channel=new(1);

endfunction

///////////////////////////BUILD_PHASE////////////////////////////////////////////////////
function void master_driver::build_phase(uvm_phase phase);
  if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
   super.build();
        super.build_phase(phase);
        endfunction


////// ///////////////////////CONNECT_PHASE////////////////////////////////////////////////////////
function void master_driver::connect_phase(uvm_phase phase);
 vif=m_cfg.vif;
endfunction

//////////////////////////////RUN PHASE/////////////////////////////////////////////////
task master_driver::run_phase(uvm_phase phase);
	forever
		begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done;
//$display("%d master driver",a);
	end
endtask

///////////////////////////////SEND TO DUT///////////////////////////////////////////////
task master_driver::send_to_dut(master_xtn xtn);
q1.push_front(xtn);
q2.push_front(xtn);
q3.push_front(xtn);
q4.push_front(xtn);
q5.push_front(xtn);
xtn.print;
	fork
		begin
		write_addr_channel.get(1);
		write_addr(q1.pop_back);
		write_addr_channel.put(1);
                  // a++;

		end

		begin
		write_data_channel.get(1);
		write_data(q2.pop_back);
		write_data_channel.put(1);
		write_resp_channel.put(1);
		end

		begin
		write_resp_channel.get(2);
		write_resp(q3.pop_back);
		write_resp_channel.put(1);
		end

		begin
		read_addr_channel.get(1);
		read_addr(q4.pop_back);
		read_addr_channel.put(1);
		read_data_channel.put(1);
		end

		begin
		read_data_channel.get(2);
		read_data(q5.pop_back);
		read_data_channel.put(1);
		end
	join_any
endtask
/////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////WRITE_ADDR_CHANNEL///////////////////////////////////////////
task master_driver::write_addr(master_xtn xtn);

@(vif.mdr_cb);
	vif.mdr_cb.awid<=xtn.awid;
	vif.mdr_cb.awaddr<=xtn.awaddr;
	vif.mdr_cb.awlen<=xtn.awlen;
	vif.mdr_cb.awsize<=xtn.awsize;
	vif.mdr_cb.awburst<=xtn.awburst;

	repeat(xtn.awvalid_delay)
	@(vif.mdr_cb);
	vif.mdr_cb.awvalid<=1;

	wait(vif.mdr_cb.awready)
	@(vif.mdr_cb);
	vif.mdr_cb.awvalid<=0;

endtask
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////WRITE_DATA_CHANNEL///////////////////////////////////////////
task master_driver::write_data(master_xtn xtn);
	vif.mdr_cb.wlast<=0;
	@(vif.mdr_cb);
		foreach(xtn.wdata[i])
		begin
		vif.mdr_cb.wdata<={xtn.wdata[i][31:24]*xtn.wstrb[i][3],xtn.wdata[i][23:16]*xtn.wstrb[i][2],xtn.wdata[i][15:8]*xtn.wstrb[i][1],xtn.wdata[i][7:0]*xtn.wstrb[i][0]};
		vif.mdr_cb.wstrb<=xtn.wstrb[i];
		@(vif.mdr_cb);
		repeat(xtn.wvalid_delay)
		@(vif.mdr_cb);
		vif.mdr_cb.wvalid<=1;
		if(i==xtn.awlen)
		vif.mdr_cb.wlast<=1;
		wait(vif.mdr_cb.wready)
		@(vif.mdr_cb);
		vif.mdr_cb.wvalid<=0;
		vif.mdr_cb.wlast<=0;
		end

endtask

/////////////////////////////////////////////////////////////////////////////////////////

////////////////////////WRITE_RESP_CHANNEL///////////////////////////////////////////
task master_driver::write_resp(master_xtn xtn);
	@(vif.mdr_cb);
		repeat(xtn.bready_delay)
		@(vif.mdr_cb);
		vif.mdr_cb.bready<=1;

		wait(vif.mdr_cb.bvalid)
		@(vif.mdr_cb);
		vif.mdr_cb.bready<=0;		
endtask

//////////////////////////////////////////////////////////////////////////////////////////

///////////////////////READ_ADDR_CHANNEL///////////////////////////////////////////
task master_driver::read_addr(master_xtn xtn);
@(vif.mdr_cb);
	vif.mdr_cb.arid<=xtn.arid;
	vif.mdr_cb.araddr<=xtn.araddr;
	vif.mdr_cb.arlen<=xtn.arlen;
	vif.mdr_cb.arsize<=xtn.arsize;
	vif.mdr_cb.arburst<=xtn.arburst;

	repeat(xtn.arvalid_delay)
	@(vif.mdr_cb);
	vif.mdr_cb.arvalid<=1;

	wait(vif.mdr_cb.arready)
	@(vif.mdr_cb);
	vif.mdr_cb.arvalid<=0;

endtask

///////////////////////////////////////////////////////////////////////////////////////

//////////////////////////READ_DATA_CHANNEL///////////////////////////////////////////
task master_driver::read_data(master_xtn xtn);
//		$display("%d",xtn.arlen+1);
		for(int i=0;i<xtn.arlen+1;i++)
		begin
		@(vif.mdr_cb);
		repeat(xtn.rready_delay)
		@(vif.mdr_cb);
		vif.mdr_cb.rready<=1;
//		$display("rready making one");	

		wait(vif.mdr_cb.rvalid)
		@(vif.mdr_cb);
		vif.mdr_cb.rready<=0;
	//	$display("rready making zero");	
		end
endtask

///////////////////////////////////////////////////////////////////////////////////////
