class slave_driver extends uvm_driver #(slave_xtn);

`uvm_component_utils(slave_driver)
virtual axi_if.SDR_MP vif;
slave_agent_config m_cfg;

	semaphore write_addr_channel;
	semaphore write_data_channel;
	semaphore write_resp_channel;
	semaphore read_addr_channel;
	semaphore read_data_channel;

	slave_xtn q1[$];
	slave_xtn q2[$];
	slave_xtn q3[$];
	slave_xtn q4[$];
	slave_xtn q5[$];

	slave_xtn awid[$];
	slave_xtn arid[$];
	slave_xtn bid[$];
extern function new(string name="slave_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task send_to_dut(slave_xtn xtn);
extern task run_phase(uvm_phase phase);
extern task write_addr(slave_xtn xtn);
extern task write_data(slave_xtn xtn);
extern task write_resp(slave_xtn xtn);
extern task read_addr(slave_xtn xtn);
extern task read_data(slave_xtn xtn);


endclass
//////////////////////////////////////CONSTUCTOR/////////////////////////////////////////////////
function slave_driver::new(string name="slave_driver",uvm_component parent);
  super.new(name,parent);
	write_addr_channel=new(1);
  	write_data_channel=new(1);
  	write_resp_channel=new(1);
  	read_addr_channel=new(1);
  	read_data_channel=new(1);
endfunction

///////////////////////////BUILD_PHASE////////////////////////////////////////////////////
function void slave_driver::build_phase(uvm_phase phase);
  if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
   super.build();
        super.build_phase(phase);
endfunction


////// ///////////////////////CONNECT_PHASE////////////////////////////////////////////////////////
function void slave_driver::connect_phase(uvm_phase phase);
 vif=m_cfg.vif;
endfunction

/////////////////////////////////RUN PHASE/////////////////////////////////////////////////
task slave_driver::run_phase(uvm_phase phase);
	forever
		begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done;
	end
endtask

////////////////////////////////////SENT TO DUT/////////////////////////////////////////////
task slave_driver::send_to_dut(slave_xtn xtn);
q1.push_front(xtn);
q2.push_front(xtn);
q3.push_front(xtn);
q4.push_front(xtn);
q5.push_front(xtn);

	fork
		begin
		write_addr_channel.get(1);
		write_addr(q1.pop_back);
		write_addr_channel.put(1);
	//	write_data_channel.put(1);
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

//////////////////////////WRITE_ADDR_CHANNEL///////////////////////////////////////////
task slave_driver::write_addr(slave_xtn xtn);

	@(vif.sdr_cb);
	//	repeat(xtn.awready_delay)
		@(vif.sdr_cb);
		vif.sdr_cb.awready<=1;
		wait(vif.sdr_cb.awvalid)
		xtn.awid=vif.sdr_cb.awid;
		xtn.awlen=vif.sdr_cb.awlen;
		xtn.awsize=vif.sdr_cb.awsize;
		xtn.awburst=vif.sdr_cb.awburst;
		xtn.awaddr=vif.sdr_cb.awaddr;
		awid.push_front(xtn);
	//	$display("%d",awid.size);
		bid.push_front(xtn);
		@(vif.sdr_cb);
		vif.sdr_cb.awready<=0;	
endtask
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////WRITE_DATA_CHANNEL///////////////////////////////////////////
task slave_driver::write_data(slave_xtn xtn);
		@(vif.sdr_cb);
      		@(vif.sdr_cb);
		@(vif.sdr_cb);
//////////////////////////////////////
		xtn=awid.pop_back;
		for(int i=0;i<xtn.awlen+1;i++)
		begin
		@(vif.sdr_cb);
		repeat(xtn.wready_delay)
		@(vif.sdr_cb);
		vif.sdr_cb.wready<=1;

		wait(vif.sdr_cb.wvalid)
		@(vif.sdr_cb);
		vif.sdr_cb.wready<=0;	
		end	
endtask

/////////////////////////////////////////////////////////////////////////////////////////

////////////////////////WRITE_RESP_CHANNEL///////////////////////////////////////////
task slave_driver::write_resp(slave_xtn xtn);
int g;
	@(vif.sdr_cb);
		g=$urandom%bid.size;
		xtn=bid[g];
		bid.delete(g);
		vif.sdr_cb.bid<=xtn.awid;
		vif.sdr_cb.bresp<=0;
		
		repeat($random%5)
		@(vif.sdr_cb);
		vif.sdr_cb.bvalid<=1;
		
		wait(vif.sdr_cb.bready)
		@(vif.sdr_cb);
		vif.sdr_cb.bvalid<=0;
		
endtask

//////////////////////////////////////////////////////////////////////////////////////////

///////////////////////READ_ADDR_CHANNEL///////////////////////////////////////////
task slave_driver::read_addr(slave_xtn xtn);
	@(vif.sdr_cb);
		repeat(xtn.arready_delay)
		@(vif.sdr_cb);
		vif.sdr_cb.arready<=1;
		wait(vif.sdr_cb.arvalid)
		xtn.arid=vif.sdr_cb.arid;
		xtn.arlen=vif.sdr_cb.arlen;
		xtn.arsize=vif.sdr_cb.arsize;
		xtn.arburst=vif.sdr_cb.arburst;
		xtn.araddr=vif.sdr_cb.araddr;
		arid.push_front(xtn);
		@(vif.sdr_cb);
		vif.sdr_cb.arready<=0;		
endtask

///////////////////////////////////////////////////////////////////////////////////////

//////////////////////////READ_DATA_CHANNEL///////////////////////////////////////////
task slave_driver::read_data(slave_xtn xtn);
	@(vif.sdr_cb);
		xtn=arid.pop_back;
		vif.sdr_cb.rid<=xtn.arid;
	//	$display("arlen %d",xtn.arlen+1);
		for(int i=0;i<xtn.arlen+1;i++)
		begin
		@(vif.sdr_cb);
		vif.sdr_cb.rdata<=$random;
		repeat($random%5)
		@(vif.sdr_cb);
		vif.sdr_cb.rvalid<=1;
		vif.sdr_cb.rresp<=0;
		if(i==xtn.arlen)
		begin
		vif.sdr_cb.rlast<=1;
  	//	$display("last signal");
		end
		wait(vif.sdr_cb.rready)
		@(vif.sdr_cb);
		vif.sdr_cb.rvalid<=0;
		vif.sdr_cb.rlast<=0;
		end	
endtask

///////////////////////////////////////////////////////////////////////////////////////


