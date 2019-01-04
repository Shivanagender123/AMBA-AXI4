class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)

uvm_tlm_analysis_fifo #(master_xtn)fifo_mh_4;
uvm_tlm_analysis_fifo #(master_xtn)fifo_mh_1;
uvm_tlm_analysis_fifo #(master_xtn)fifo_mh_2;
uvm_tlm_analysis_fifo #(master_xtn)fifo_mh_3;
uvm_tlm_analysis_fifo #(master_xtn)fifo_mh_5;

uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh_4;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh_1;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh_2;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh_3;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_sh_5;

master_xtn master_data_1;
master_xtn master_data_2;
master_xtn master_data_3;
master_xtn master_data_4;
master_xtn master_data_5;

master_xtn master_data_1_[$];
master_xtn master_data_2_[$];
master_xtn master_data_3_[$];
master_xtn master_data_4_[$];
master_xtn master_data_5_[$];

slave_xtn slave_data_1;
slave_xtn slave_data_2;
slave_xtn slave_data_3;
slave_xtn slave_data_4;
slave_xtn slave_data_5;

slave_xtn slave_data_1_[$];
slave_xtn slave_data_2_[$];
slave_xtn slave_data_3_[$];
slave_xtn slave_data_4_[$];
slave_xtn slave_data_5_[$];

env_config m_cfg;

int wtrans=1,rtrans=1;

static int c;

extern function new(string name="scoreboard",uvm_component parent=null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void check_phase(uvm_phase phase);

endclass

function scoreboard::new(string name="scoreboard",uvm_component parent);
 super.new(name,parent);

endfunction


function void scoreboard::build_phase(uvm_phase phase);
	super.build_phase (phase);
	fifo_mh_1=new("master fifo 1",this);
	fifo_mh_2=new("master fifo 2",this);
	fifo_mh_3=new("master fifo 3",this);
	fifo_mh_4=new("master fifo 4",this);
	fifo_mh_5=new("master fifo 5",this);
	fifo_sh_1=new("slave fifo 1",this);
	fifo_sh_2=new("slave fifo 2",this);
	fifo_sh_3=new("slave fifo 3",this);
	fifo_sh_4=new("slave fifo 4",this);
	fifo_sh_5=new("slave fifo 5",this);
endfunction


task scoreboard::run_phase(uvm_phase phase);
	fork
		forever
			begin
			fifo_mh_1.get(master_data_1);
			master_data_1_.push_back(master_data_1);
			end
		forever
			begin
			fifo_mh_2.get(master_data_2);
			master_data_2_.push_back(master_data_2);
			end
		forever
			begin
			fifo_mh_3.get(master_data_3);
			master_data_3_.push_back(master_data_3);
			end
		forever
			begin
			fifo_mh_4.get(master_data_4);
			master_data_4_.push_back(master_data_4);
			end
		forever
			begin
			fifo_mh_5.get(master_data_5);
			master_data_5_.push_back(master_data_5);
			end
		forever
			begin
			fifo_sh_1.get(slave_data_1);
			slave_data_1_.push_back(slave_data_1);
			end
		forever
			begin
			fifo_sh_2.get(slave_data_2);
			slave_data_2_.push_back(slave_data_2);
			end
		forever
			begin
			fifo_sh_3.get(slave_data_3);
			slave_data_3_.push_back(slave_data_3);
			end
		forever
			begin
			fifo_sh_4.get(slave_data_4);
			slave_data_4_.push_back(slave_data_4);
			end
		forever
			begin
			fifo_sh_5.get(slave_data_5);
			slave_data_5_.push_back(slave_data_5);
			end
	join
endtask

function void scoreboard::check_phase(uvm_phase phase);
	foreach(master_data_1_[i])
         		begin
                     c++;
  $display("%d scoreboard ",c);

		if(master_data_1_[i].awlen!=slave_data_1_[i].awlen ||master_data_1_[i].awburst!=slave_data_1_[i].awburst ||master_data_1_[i].awaddr!=slave_data_1_[i].awaddr ||master_data_1_[i].awsize!=slave_data_1_[i].awsize ||master_data_1_[i].awid!=slave_data_1_[i].awid)
			`uvm_fatal("SB",$sformatf("********%dwrite Address  communicated improperly*************",i));
		end
	$display("***********************All Write Address communicated properly**************");

	foreach(master_data_2_[i])
		begin
		slave_data_2=slave_data_2_[i];
		master_data_2=master_data_2_[i];
		foreach(master_data_2.wdata[i])
		begin
			if(master_data_2.wdata[i]!=slave_data_2.wdata[i])
			`uvm_fatal("SB",$sformatf("********%dth transaction %dth write data is mismatched***********",wtrans,i))
		end
		wtrans++;
		end
	$display("***********************All Write Data transferred properly**************");
	
	foreach(master_data_3_[i])
		begin
		if(master_data_3_[i].bid!=slave_data_3_[i].bid ||master_data_3_[i].bresp!=slave_data_3_[i].bresp)
			`uvm_fatal("SB",$sformatf("********%d Response of id %d communicated improperly*************",i,master_data_3_[i].bid));
		end
		$display("***********************All Responses communicated properly**************");

	foreach(master_data_4_[i])
		begin
		if(master_data_4_[i].arlen!=slave_data_4_[i].arlen ||master_data_4_[i].arburst!=slave_data_4_[i].arburst ||master_data_4_[i].araddr!=slave_data_4_[i].araddr ||master_data_4_[i].arsize!=slave_data_4_[i].arsize ||master_data_4_[i].arid!=slave_data_4_[i].arid)
			`uvm_fatal("SB",$sformatf("********%d Read Address  communicated improperly*************",i));
		end
	$display("***********************All Read Address communicated properly**************");

	foreach(master_data_5_[i])
		begin
		slave_data_5=slave_data_5_[i];
		master_data_5=master_data_5_[i];
		foreach(master_data_5.rdata[i])
		begin
			if(master_data_5.rdata[i]!=slave_data_5.rdata[i])
			begin
				begin
				slave_data_5.print;
				master_data_5.print;
				end
			`uvm_fatal("SB",$sformatf("********%dth transaction %dth read data is mismatched***********",rtrans,i))
			end
		end
		rtrans++;
		end
	$display("***********************All Read Data transferred properly**************");
endfunction



