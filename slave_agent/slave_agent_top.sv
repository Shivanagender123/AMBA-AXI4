class slave_agent_top extends uvm_env;
 
`uvm_component_utils(slave_agent_top)

	slave_agent agent[];
	env_config m_cfg;


extern function new(string name="slave_agent_top",uvm_component parent);
extern function void build_phase(uvm_phase phase);
endclass


function slave_agent_top::new(string name="slave_agent_top",uvm_component parent);
super.new(name,parent);
endfunction



function  void slave_agent_top::build_phase(uvm_phase phase);
if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 

super.build_phase(phase);

if(m_cfg.has_slave_agent)
     agent=new[m_cfg.no_of_slave_agents];
      foreach(agent[i])
	begin
           uvm_config_db #(slave_agent_config)::set(this,$sformatf("agent[%0d]*",i), "slave_agent_config", m_cfg.m_slave_agent_cfg[i]);
 agent[i]=slave_agent::type_id::create($sformatf("agent[%0d]",i),this);
end
        endfunction


