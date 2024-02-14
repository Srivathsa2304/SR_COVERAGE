class sr_coverage extends uvm_subscriber#(sr_sequence_item);

  `uvm_component_utils(sr_coverage)
  uvm_analysis_imp#(sr_sequence_item, sr_coverage) item_got_export1;

  sr_sequence_item tr;

covergroup cg_in;
   option.per_instance= 1;
    option.comment     = "coverage";
    option.name        = "functional_cov";
  option.auto_bin_max=4;

  s:coverpoint tr.s;

  r:coverpoint tr.r;
  sxr: cross s,r;

endgroup
  
covergroup cg_out;
    option.per_instance= 1;
    option.comment     = "coverage";
    option.name        = "functional_cov";
  option.auto_bin_max=4;

  q: coverpoint tr.q;

  qbar: coverpoint tr.qbar;


endgroup

 

function new(string name="sr_coverage",uvm_component parent);

  super.new(name,parent);

  item_got_export1= new("item_got_export1", this);

  tr=sr_sequence_item::type_id::create("tr");

  cg_in=new();
  
  cg_out=new();

endfunction

 

  function void write(sr_sequence_item t);

   tr=t;

   cg_in.sample();

    $display("input coverage =%0d ",cg_in.get_coverage());
     cg_out.sample();

    $display("output coverage =%0d ",cg_out.get_coverage());

endfunction

endclass