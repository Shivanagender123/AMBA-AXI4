class tb extends uvm_env;
`uvm_component_utils(tb);
master_agent_top master_top;
slave_agent_top slave_top;
env_config m_cfg;
virtual_sequencer vseqrh;
scoreboard sb;

extern function new(string name="tb",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern function void start_of_simulation_phase(uvm_phase phase);

endclass
//////////////////////////////////NEW_PHASE//////////////////////////////////////////////////////////////////

function tb::new(string name="tb",uvm_component parent);
  super.new(name,parent);
endfunction

//////////////////////////////////BUILD_PHASE//////////////////////////////////////////////////////////
function void tb::build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 

if(m_cfg.has_master_agent)
      
     master_top=master_agent_top::type_id::create("master_top",this);

if(m_cfg.has_slave_agent)
      
     slave_top=slave_agent_top::type_id::create("slave_top",this);



if(m_cfg.has_virtual_sequencer)
vseqrh=virtual_sequencer::type_id::create("vseqrh",this);



if(m_cfg.has_scoreboard)
sb=scoreboard::type_id::create("sb",this);
        endfunction


/////////////////////////////connect_phase/////////////////////////////////////




function void tb::connect_phase(uvm_phase phase);
          if(m_cfg.has_virtual_sequencer) begin
               if(m_cfg.has_master_agent)
			begin
           		
                          	for(int i=0; i<m_cfg.no_of_master_agents;i++)

		                       vseqrh.master_seqrh[i] = master_top.agent[i].m_sequencer;
				for(int i=0; i<m_cfg.no_of_slave_agents;i++)

		                       vseqrh.slave_seqrh[i] = slave_top.agent[i].m_sequencer;
			end
                                            end


             /*     if(m_cfg.has_scoreboard) begin
    		 
		                      master_top.agent[0].monh.monitor_port_1.connect(sb.fifo_mh_1.analysis_export);
		                     master_top.agent[0].monh.monitor_port_2.connect(sb.fifo_mh_2.analysis_export);
		                     master_top.agent[0].monh.monitor_port_3.connect(sb.fifo_mh_3.analysis_export);
		                     master_top.agent[0].monh.monitor_port_4.connect(sb.fifo_mh_4.analysis_export);
		                     master_top.agent[0].monh.monitor_port_5.connect(sb.fifo_mh_5.analysis_export);
			        slave_top.agent[0].monh.monitor_port_1.connect(sb.fifo_sh_1.analysis_export);
			        slave_top.agent[0].monh.monitor_port_2.connect(sb.fifo_sh_2.analysis_export);
			        slave_top.agent[0].monh.monitor_port_3.connect(sb.fifo_sh_3.analysis_export);
			        slave_top.agent[0].monh.monitor_port_4.connect(sb.fifo_sh_4.analysis_export);
			        slave_top.agent[0].monh.monitor_port_5.connect(sb.fifo_sh_5.analysis_export);
		                      			end*/
		if(m_cfg.has_scoreboard) begin
				master_top.agent[0].monh.monitor_port_w.connect(sb.fifo_m_w.analysis_export);
				master_top.agent[0].monh.monitor_port_r.connect(sb.fifo_m_r.analysis_export);
				slave_top.agent[0].monh.monitor_port_w.connect(sb.fifo_s_w.analysis_export);
				slave_top.agent[0].monh.monitor_port_r.connect(sb.fifo_s_r.analysis_export);
					end
                                
                                                                   
					      
endfunction

///////////////////////////START_OF_SIMULATION_PHASE//////////////////////////////////////////////////////////

function void tb::start_of_simulation_phase(uvm_phase phase);
       uvm_top.print_topology;
endfunction

