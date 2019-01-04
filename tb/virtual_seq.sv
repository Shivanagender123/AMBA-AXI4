class virtual_seq extends uvm_sequence #(uvm_sequence_item);

`uvm_object_utils(virtual_seq); 

master_sequencer master_seqrh[];
slave_sequencer slave_seqrh[];
env_config m_cfg;
virtual_sequencer vsqrh;
extern function new(string name="virtual_seq");
extern task body();
endclass

function virtual_seq::new(string name="virtual_Seq");
super.new(name);
endfunction
task virtual_seq::body();
	  if(!uvm_config_db #(env_config)::get(null,get_full_name(),"env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")

  master_seqrh = new[m_cfg.no_of_master_agents];
 slave_seqrh = new[m_cfg.no_of_slave_agents];
  
  
  assert($cast(vsqrh,m_sequencer)) else begin
    `uvm_error("BODY", "Error in $cast of virtual sequencer")
  end

 foreach(master_seqrh[i])
  master_seqrh[i] = vsqrh.master_seqrh[i];
foreach(slave_seqrh[i])
  slave_seqrh[i] = vsqrh.slave_seqrh[i];
endtask: body



 class vseq1 extends virtual_seq;

	`uvm_object_utils(vseq1) 
	master_seq1 mseq1;
	slave_seq1 sseq1;
       	extern function new(string name ="vseq1");
	extern task body();
	endclass 
//-----------------  constructor new method  -------------------//

 
	function vseq1::new(string name ="vseq1");
		super.new(name);
	endfunction
	task vseq1::body;
		super.body;
		mseq1=master_seq1::type_id::create("MASTER_SEQ");
		sseq1=slave_seq1::type_id::create("SLAVE_SEQ");
		fork
		mseq1.start(master_seqrh[0]);
		sseq1.start(slave_seqrh[0]);
		join
	endtask


