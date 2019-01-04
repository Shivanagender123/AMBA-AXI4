class master_agent extends  uvm_agent;

`uvm_component_utils(master_agent)

master_agent_config m_cfg;
master_driver drvh;
master_monitor monh;
master_sequencer m_sequencer;

extern function new(string name="master_agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass


function master_agent::new(string name="master_agent",uvm_component parent);
super.new(name,parent);
endfunction


function void master_agent::build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
       
  monh=master_monitor::type_id::create("monh",this);
if(m_cfg.is_active==UVM_ACTIVE)
	begin
    	 drvh=master_driver::type_id::create("drvh",this);
     m_sequencer=master_sequencer::type_id::create("m_sequencer",this);
	end
endfunction


function void master_agent::connect_phase(uvm_phase phase);
if(m_cfg.is_active==UVM_ACTIVE)
begin
drvh.seq_item_port.connect(m_sequencer.seq_item_export);
end
endfunction
