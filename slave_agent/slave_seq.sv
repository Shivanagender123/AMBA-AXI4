class slave_seq extends uvm_sequence;

`uvm_object_utils(slave_seq); 



extern function new(string name="slave_seq");
endclass

function slave_seq::new(string name="slave_Seq");
super.new(name);
endfunction


class slave_seq1 extends slave_seq;

`uvm_object_utils(slave_seq1)
extern function new(string name="slave_seq1");
extern task body;

endclass

function slave_seq1::new(string name="slave_seq1");
super.new(name);
endfunction

task slave_seq1::body;
repeat(1)
begin
req=slave_xtn::type_id::create("slave_XTN");
start_item(req);
assert(req.randomize );
finish_item(req);
end
endtask
