class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)

uvm_tlm_analysis_fifo #(master_xtn)fifo_m_w;
uvm_tlm_analysis_fifo #(master_xtn)fifo_m_r;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_s_w;
uvm_tlm_analysis_fifo #(slave_xtn)fifo_s_r;
 
env_config m_cfg;

master_xtn wr_xtn1;
master_xtn rd_xtn1;

slave_xtn wr_xtn2;
slave_xtn rd_xtn2;

master_xtn master_wr_xtn[$];
master_xtn master_rd_xtn[$];
slave_xtn slave_wr_xtn[$];
slave_xtn slave_rd_xtn[$];

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
	fifo_m_w=new("fifo_m_w",this);
	fifo_m_r=new("fifo_m_r",this);
	fifo_s_w=new("fifo_s_w",this);
	fifo_s_r=new("fifo_s_r",this);

endfunction


task scoreboard::run_phase(uvm_phase phase);
	fork
		forever
			begin
			fifo_m_w.get(wr_xtn1);
			master_wr_xtn.push_back(wr_xtn1);
			end
		forever
			begin
			fifo_m_r.get(rd_xtn1);
			master_rd_xtn.push_back(rd_xtn1);
			end
		forever
			begin
			fifo_s_w.get(wr_xtn2);
			slave_wr_xtn.push_back(wr_xtn2);
			end
		forever
			begin
			fifo_s_r.get(rd_xtn2);
			slave_rd_xtn.push_back(rd_xtn2);
			end
		join
endtask

function void scoreboard::check_phase(uvm_phase phase);
	foreach(master_wr_xtn[i])
		begin
	if(master_wr_xtn[i].awlen!=slave_wr_xtn[i].awlen ||master_wr_xtn[i].awburst!=slave_wr_xtn[i].awburst ||master_wr_xtn[i].awaddr!=slave_wr_xtn[i].awaddr ||master_wr_xtn[i].awsize!=slave_wr_xtn[i].awsize ||master_wr_xtn[i].awid!=slave_wr_xtn[i].awid)
	`uvm_fatal("SB",$sformatf("********%dwrite Address  communicated improperly*************",i));
		end
	$display("***********************All Write Address communicated properly**************");

	foreach(master_wr_xtn[i])
		begin
		wr_xtn2=slave_wr_xtn[i];
		wr_xtn1=master_wr_xtn[i];
		foreach(wr_xtn1.wdata[i])
		begin
			if(wr_xtn1.wdata[i]!=wr_xtn2.wdata[i])
			`uvm_fatal("SB",$sformatf("********%dth transaction %dth write data is mismatched***********",wtrans,i))
		end
		wtrans++;
		end
	$display("***********************All Write Data transferred properly**************");
	foreach(master_wr_xtn[i])
		begin
		if(master_wr_xtn[i].bid!=slave_wr_xtn[i].bid ||master_wr_xtn[i].bresp!=slave_wr_xtn[i].bresp)
			`uvm_fatal("SB",$sformatf("********%d Response of id %d communicated improperly*************",i,master_wr_xtn[i].bid));
		end
		$display("***********************All Responses communicated properly**************");

	foreach(master_rd_xtn[i])
		begin
		if(master_rd_xtn[i].arlen!=slave_rd_xtn[i].arlen ||master_rd_xtn[i].arburst!=slave_rd_xtn[i].arburst ||master_rd_xtn[i].araddr!=slave_rd_xtn[i].araddr ||master_rd_xtn[i].arsize!=slave_rd_xtn[i].arsize ||master_rd_xtn[i].arid!=slave_rd_xtn[i].arid)
			`uvm_fatal("SB",$sformatf("********%d Read Address  communicated improperly*************",i));
		end
	$display("***********************All Read Address communicated properly**************");

	foreach(master_rd_xtn[i])
		begin
		rd_xtn2=slave_rd_xtn[i];
		rd_xtn1=master_wr_xtn[i];
		foreach(rd_xtn1.rdata[i])
		begin
			if(rd_xtn1.rdata[i]!=rd_xtn2.rdata[i])
			begin
				begin
				rd_xtn2.print;
				rd_xtn1.print;
				end
			`uvm_fatal("SB",$sformatf("********%dth transaction %dth read data is mismatched***********",rtrans,i))
			end
		end
		rtrans++;
		end
	$display("***********************All Read Data transferred properly**************");


endfunction



