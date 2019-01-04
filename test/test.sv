	class base_test extends uvm_test;

   // Factory Registration
	`uvm_component_utils(base_test)

  
         // Handles 
    		 tb envh;
        	 env_config m_tb_cfg;
        	master_agent_config m_master_cfg[];
        	slave_agent_config m_slave_cfg[];
		           
       		  int has_master_agent = 1;
	         int no_of_master_agents=1;
           
       		  int has_slave_agent = 1;
	         int no_of_slave_agents=1;
//////////////////////////////////  Standard UVM Methods: /////////////////////////////////////////////////////////////////

	extern function new(string name = "base_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void config_axi();
        
        endclass
        
////////////////////////////////////// constructor new method  //////////////////////////////////////////////////////

function base_test::new(string name = "base_test", uvm_component parent);
		super.new(name,parent);
endfunction

function void base_test::config_axi();
 	   if (has_master_agent) begin
            m_master_cfg=new[no_of_master_agents];
		foreach(m_master_cfg[i])
		begin
                      m_master_cfg[i]=master_agent_config::type_id::create($sformatf("m_master_cfg[%0d]",i));


         	 if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_%0d",i),m_master_cfg[i].vif))
		`uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?")
             m_master_cfg[i].is_active = UVM_ACTIVE;

	                m_tb_cfg.m_master_agent_cfg[i] = m_master_cfg[i];
                
                end 
             end
	 if (has_slave_agent) begin
            m_slave_cfg=new[no_of_slave_agents];
		foreach(m_slave_cfg[i])
		begin
                      m_slave_cfg[i]=slave_agent_config::type_id::create($sformatf("m_slave_cfg[%0d]",i));


         	 if(!uvm_config_db #(virtual axi_if)::get(this,"",$sformatf("vif_%0d",i),m_slave_cfg[i].vif))
		`uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?")
             m_slave_cfg[i].is_active = UVM_ACTIVE;

	                m_tb_cfg.m_slave_agent_cfg[i] = m_slave_cfg[i];
                
                end 
             end

			                  m_tb_cfg.has_master_agent = has_master_agent;
					   m_tb_cfg.has_slave_agent = has_slave_agent;
					 m_tb_cfg.no_of_master_agents = no_of_master_agents;
					   m_tb_cfg.no_of_slave_agents = no_of_slave_agents;
endfunction



function void base_test::build_phase(uvm_phase phase);
      	        m_tb_cfg=env_config::type_id::create("m_tb_cfg");
              if(has_master_agent)
     		m_tb_cfg.m_master_agent_cfg=new[no_of_master_agents];
	  if(has_slave_agent)
    		 m_tb_cfg.m_slave_agent_cfg=new[no_of_slave_agents];
                     // Call function 
                config_axi(); 
	uvm_config_db #(env_config)::set(this,"*","env_config",m_tb_cfg);
		
     		super.build();
		envh=tb::type_id::create("envh", this);
endfunction

class test1 extends base_test;

   // Factory Registration
	`uvm_component_utils(test1)
	vseq1 v1;
	extern function new(string name = "test1",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
        extern task run_phase (uvm_phase phase);
        endclass
        
////////////////////////////////////// constructor new method  //////////////////////////////////////////////////////

   	function test1::new(string name = "test1", uvm_component parent);
		super.new(name,parent);
	 endfunction

	function void test1::build_phase(uvm_phase phase);
	super.build_phase(phase);
	endfunction

	task test1::run_phase (uvm_phase phase);
		phase.raise_objection(this);
		v1=vseq1::type_id::create("V_SEQ");
		v1.start(envh.vseqrh);
	#1000;
	        		phase.drop_objection(this);
	endtask




