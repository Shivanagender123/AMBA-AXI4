class master_seq extends uvm_sequence#(master_xtn);

`uvm_object_utils(master_seq); 



extern function new(string name="master_seq");
endclass

function master_seq::new(string name="master_Seq");
super.new(name);
endfunction


class master_seq1 extends master_seq;

`uvm_object_utils(master_seq1)
extern function new(string name="master_seq1");
extern task body;

endclass

function master_seq1::new(string name="master_seq1");
super.new(name);
endfunction

task master_seq1::body;
repeat(1)
begin
req=master_xtn::type_id::create("master_XTN");
start_item(req);
assert(req.randomize );
finish_item(req);
end
endtask
