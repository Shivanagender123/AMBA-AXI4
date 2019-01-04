class env_config extends uvm_object;

`uvm_object_utils(env_config)

// Whether env analysis components are used:
bit has_functional_coverage = 0;
bit has_wagent_functional_coverage = 0;
bit has_scoreboard = 1;
// Whether the various agents are used:
bit has_master_agent = 1;
bit has_slave_agent=1;
// Whether the virtual sequencer is used:
bit has_virtual_sequencer = 1;

int no_of_slave_agents=1;
int no_of_master_agents=1;
//dynamicc configh files
                 master_agent_config m_master_agent_cfg[];
		slave_agent_config m_slave_agent_cfg[];




// Standard UVM Methods:
extern function new(string name = "env_config");

endclass
//-----------------  constructor new method  -------------------//

function env_config::new(string name = "env_config");
  super.new(name);
endfunction
