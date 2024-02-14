// Code your testbench here
// or browse Examples
// Assessment
// Date:-7/2/2024
// Write coverage class for given design of SR latch with uvm subscriber add following options in covergorup
// 1.Add option for pre instance as 1.
// 2.  add option for comment 
// 3. add option for name  as “functional cov”
// 4. add option for auto bin max as 4
// Also modify stimulus if required to get coverage  more than 95%.
// Generate coverage report for functional and code coverage.

//package
`ifndef TB_PKG
`define TB_PKG

package tb_pkg;
import uvm_pkg::*;
// `include "sr_sequence_item.sv"        // transaction class
// `include "sr_sequence.sv"             // sequence class
// `include "sr_sequencer.sv"            // sequencer class
// `include "sr_driver.sv"               // driver class
// `include "sr_monitor.sv"              // monitor class
// `include "sr_agent.sv"                // agent class  
// `include "sr_coverage.sv"             // coverage class
// `include "sr_scoreboard.sv"           // scorebaord class
// `include "sr_env.sv"                  // environment class
 
// `include "sr_test.sv"                   // test1
//`include "test2.sv"
//`include "test3.sv"

endpackage
`endif
//end of package

// ----------------------------------------------interface.sv---------------------------------------------------------------------
interface intf();
    // ------------------- port declaration-------------------------------------
    logic s;
    logic r;
    logic q;
    logic qbar;
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
        
endinterface

// ---------------------------------------------------testbench.sv-----------------------------------------------------------------------
//`include "interface.sv"
//`include "tb_pkg.sv"
module top;
  import uvm_pkg::*;
   `include "uvm_macros.svh"
  import tb_pkg::*;
  

  //----------------------------------------------------------------------------
  intf i_intf();
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  sr DUT(.s(i_intf.s),
         .r(i_intf.r),
         .q(i_intf.q),
         .qbar(i_intf.qbar)
        );
  //----------------------------------------------------------------------------               
  
  //----------------------------------------------------------------------------
  initial begin
    $dumpfile("dumpfile.vcd");
    $dumpvars;
  end
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual intf)::set(uvm_root::get(),"","vif",i_intf);
  end
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  initial begin
    run_test("sr_test");
  end
  //----------------------------------------------------------------------------
endmodule
// ------------------------------------ ---------------------------------TEST.sv-----------------------------------------------------------

class sr_test extends uvm_test;

    //--------------------------------------------------------------------------
    `uvm_component_utils(sr_test)
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    function new(string name="sr_test",uvm_component parent);
	   super.new(name,parent);
    endfunction
    //--------------------------------------------------------------------------

    sr_env env_h;
    int file_h;

    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env_h = sr_env::type_id::create("env_h",this);
    endfunction
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    function void end_of_elobartion_phase(uvm_phase phase);
      //factory.print();
      $display("End of eleboration phase in agent");
    endfunction
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    function void start_of_simulation_phase(uvm_phase phase);
      $display("start_of_simulation_phase");
      file_h=$fopen("LOG_FILE.log","w");
      set_report_default_file_hier(file_h);
      set_report_severity_action_hier(UVM_INFO,UVM_DISPLAY+UVM_LOG);
      set_report_verbosity_level_hier(UVM_MEDIUM);
    endfunction
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        sr_sequence seq;
        sequence_1 seq1;
        sequence_2 seq2;
        sequence_3 seq3;
	      phase.raise_objection(this);
            
            seq = sr_sequence::type_id::create("seq");
            seq1= sequence_1::type_id::create("seq1");
            seq2= sequence_2::type_id::create("se2");
            seq3= sequence_3::type_id::create("se3");

            seq.start(env_h.agent_h.sequencer_h);
            seq1.start(env_h.agent_h.sequencer_h);
            seq2.start(env_h.agent_h.sequencer_h);
            seq3.start(env_h.agent_h.sequencer_h);

            #10;
	      phase.drop_objection(this);
    endtask
    //--------------------------------------------------------------------------

endclass:sr_test


// ---------------------------------------------------env.sv--------------------------------------------------------------------------------

class sr_env extends uvm_env;

   //---------------------------------------------------------------------------
   `uvm_component_utils(sr_env)
   //---------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function new(string name="sr_env",uvm_component parent);
    super.new(name,parent);
  endfunction
  //----------------------------------------------------------------------------

  //-------------------- class handles -----------------------------------------
  sr_agent    agent_h;
  sr_coverage coverage_h;
  sr_scoreboard scoreboard_h;
  //----------------------------------------------------------------------------

  //---------------------- build phase -----------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_h    = sr_agent::type_id::create("agent_h",this);
    coverage_h = sr_coverage::type_id::create("coverage_h",this);
    scoreboard_h = sr_scoreboard::type_id::create("scoreboard_h",this);
  endfunction
  //----------------------------------------------------------------------------

  //-------------------------- connect phase -----------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent_h.monitor_h.ap_mon.connect(coverage_h.analysis_export);
    // monitor to scoreboard connection
    agent_h.monitor_h.ap_mon.connect(scoreboard_h.aport_mon);
    // driver to scoreboard connection 
    agent_h.driver_h.drv2sb.connect(scoreboard_h.aport_drv);
    //coverage
    
  endfunction
  //----------------------------------------------------------------------------
endclass:sr_env
// ---------------------------------------------------------Agent.sv----------------------------------------------------------------------
class sr_agent extends uvm_agent;

  //----------------------------------------------------------------------------
  `uvm_component_utils(sr_agent)
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function new(string name="sr_agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  //----------------------------------------------------------------------------

  //----------------- class handles --------------------------------------------
  sr_sequencer sequencer_h;
  sr_driver    driver_h;
  sr_monitor   monitor_h;
  //----------------------------------------------------------------------------

  //---------------------- build phase -----------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver_h    = sr_driver::type_id::create("driver_h",this);
    sequencer_h = sr_sequencer::type_id::create("sequencer_h",this);
    monitor_h   = sr_monitor::type_id::create("monitor_h",this);
  endfunction
  //----------------------------------------------------------------------------

  //----------------------- connect phase --------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
  endfunction
  //----------------------------------------------------------------------------

endclass:sr_agent

// -----------------------------------------------------------------sequencer.sv------------------------------------------------------
class sr_sequencer extends uvm_sequencer#(sr_sequence_item);
  //----------------------------------------------------------------------------
  `uvm_component_utils(sr_sequencer)  
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function new(string name="sr_sequencer",uvm_component parent);  
    super.new(name,parent);
  endfunction
  //----------------------------------------------------------------------------
  
endclass:sr_sequencer


// --------------------------------------------------------------------driver.sv------------------------------------------------------------
class sr_driver extends uvm_driver #(sr_sequence_item);
  //----------------------------------------------------------------------------
  `uvm_component_utils(sr_driver)
  //----------------------------------------------------------------------------

  uvm_analysis_port #(sr_sequence_item) drv2sb;

  //----------------------------------------------------------------------------
  function new(string name="sr_driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  //---------------------------------------------------------------------------- 

  //--------------------------  virtual interface handel -----------------------  
  virtual interface intf vif;
  //----------------------------------------------------------------------------
  
  //-------------------------  get interface handel from top -------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif))) begin
      `uvm_fatal("driver","unable to get interface");
    end
    drv2sb=new("drv2sb",this);
  endfunction
  //----------------------------------------------------------------------------
  
  //---------------------------- run task --------------------------------------
  task run_phase(uvm_phase phase);
    sr_sequence_item txn=sr_sequence_item::type_id::create("txn");
    initilize(); // initilize dut at time 0
    forever begin
      seq_item_port.get_next_item(txn);
      drive_item(txn);
      drv2sb.write(txn);
      seq_item_port.item_done();    
    end
  endtask
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  task initilize();
   // make changes here for input to dut 
   // vif.data = 0;
   // vif.addr = 0;
   // vif.read = 0;
   vif.s = 0;
   vif.r = 0;
  endtask
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  task drive_item(sr_sequence_item txn);
    // make changes here
    // @(posedge vif.clk);
    // vif.cb.data = txn.data;
    // vif.cb.addr = txn.addr;
    // vif.cb.read = txn.read;
    vif.s = txn.s;
    vif.r = txn.r;
  endtask
  //----------------------------------------------------------------------------
endclass:sr_driver


// --------------------------------------------------------monitor.sv---------------------------------------------------------------------
class sr_monitor extends uvm_monitor;
  //----------------------------------------------------------------------------
  `uvm_component_utils(sr_monitor)
  //----------------------------------------------------------------------------

  //------------------- constructor --------------------------------------------
  function new(string name="sr_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  //----------------------------------------------------------------------------
  
  //---------------- sequence_item class ---------------------------------------
  sr_sequence_item  txn;
  //----------------------------------------------------------------------------
  
  //------------------------ virtual interface handle---------------------------  
  virtual interface intf vif;
  //----------------------------------------------------------------------------

  //------------------------ analysis port -------------------------------------
  uvm_analysis_port#(sr_sequence_item) ap_mon;
  //----------------------------------------------------------------------------
  
  //------------------- build phase --------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif)))
    begin
      `uvm_fatal("monitor","unable to get interface")
    end
    
    ap_mon=new("ap_mon",this);
  endfunction
  //----------------------------------------------------------------------------

  //-------------------- run phase ---------------------------------------------
  task run_phase(uvm_phase phase);
    sr_sequence_item txn=sr_sequence_item::type_id::create("txn");
    forever
    begin
      sample_dut(txn);
      ap_mon.write(txn);
    end
  endtask
  //----------------------------------------------------------------------------

  task sample_dut(output sr_sequence_item txn);
    sr_sequence_item t = sr_sequence_item::type_id::create("t");
    #5.1;
    t.s    = vif.s;
    t.r    = vif.r;
    t.q    = vif.q;
    t.qbar = vif.qbar;
    txn    = t;
  endtask : sample_dut

endclass:sr_monitor

// --------------------------------------------------------scoreboard.sv----------------------------------------------------------------
/***************************************************
  analysis_port from driver
  analysis_port from monitor
***************************************************/

`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon )

class sr_scoreboard extends uvm_scoreboard;
  //----------------------------------------------------------------------------
  `uvm_component_utils(sr_scoreboard)
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  uvm_analysis_imp_drv #(sr_sequence_item, sr_scoreboard) aport_drv;
  uvm_analysis_imp_mon #(sr_sequence_item, sr_scoreboard) aport_mon;
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  uvm_tlm_fifo #(sr_sequence_item) expfifo;
  uvm_tlm_fifo #(sr_sequence_item) outfifo;
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  int VECT_CNT, PASS_CNT, ERROR_CNT;
  logic t_s;
  logic t_r;
  logic t_q,temp_q;
  logic t_qbar,temp_qbar;

  function new(string name="sr_scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------  
  function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
  	aport_drv = new("aport_drv", this);
  	aport_mon = new("aport_mon", this);
  	expfifo= new("expfifo",this);
  	outfifo= new("outfifo",this);
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function void write_drv(sr_sequence_item tr);
    `uvm_info("write_drv STIM", tr.input2string(), UVM_MEDIUM)
    t_r = tr.r;
    t_s = tr.s;
    t_q = temp_q;
    t_qbar = temp_qbar;

    if(t_s==0 && t_r==0) begin 
      temp_q    =  temp_q;
      temp_qbar = ~temp_q;
    end
    else if(t_s==0 && t_r==1) begin 
      temp_q    =  0;
      temp_qbar = ~temp_q;
    end
    else if(t_s==1 && t_r==0) begin 
      temp_q    =  1;
      temp_qbar = ~temp_q;
    end
    else begin 
      temp_q    = 1'bx;
      temp_qbar = ~temp_q;
    end

    tr.q    = t_q;
    tr.qbar = t_qbar;

    void'(expfifo.try_put(tr));
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function void write_mon(sr_sequence_item tr);
    `uvm_info("write_mon OUT ", tr.convert2string(), UVM_MEDIUM)
    void'(outfifo.try_put(tr));
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
	sr_sequence_item exp_tr, out_tr;
  static int unsigned count=0;
	forever begin
	    `uvm_info("scoreboard run task","WAITING for expected output", UVM_DEBUG)
	    expfifo.get(exp_tr);
	    `uvm_info("scoreboard run task","WAITING for actual output", UVM_DEBUG)
	    outfifo.get(out_tr);
        
        if (out_tr.q===exp_tr.q && out_tr.qbar===exp_tr.qbar && count>0) begin
            PASS();
          `uvm_info ("\n [ PASS ",out_tr.convert2string() , UVM_MEDIUM)
	      end
      
      	else if (out_tr.q!==exp_tr.q && out_tr.qbar!==exp_tr.qbar && count>0) begin
	         ERROR();
          `uvm_info ("ERROR [ACTUAL_OP]",out_tr.convert2string() , UVM_MEDIUM)
          `uvm_info ("ERROR [EXPECTED_OP]",exp_tr.convert2string() , UVM_MEDIUM)
          `uvm_warning("ERROR",exp_tr.convert2string())
	      end
        count++;
    end
  endtask
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (VECT_CNT && !ERROR_CNT)
            `uvm_info("PASSED",$sformatf("*** TEST PASSED - %0d vectors ran, %0d vectors passed ***",
            VECT_CNT, PASS_CNT), UVM_LOW)

        else
            `uvm_info("FAILED",$sformatf("*** TEST FAILED - %0d vectors ran, %0d vectors passed, %0d vectors failed ***",
            VECT_CNT, PASS_CNT, ERROR_CNT), UVM_LOW)
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function void PASS();
	  VECT_CNT++;
	  PASS_CNT++;
  endfunction

  function void ERROR();
  	VECT_CNT++;
  	ERROR_CNT++;
  endfunction
  //----------------------------------------------------------------------------
endclass
    
    
// ----------------------Coverage----------------------------------
    
    class sr_coverage extends uvm_subscriber#(sr_sequence_item);

  `uvm_component_utils(sr_coverage)
  uvm_analysis_imp#(sr_sequence_item, sr_coverage) item_got_export1;

  sr_sequence_item tr;

covergroup cg_in;
  option.auto_bin_max=10;

  s_cov:coverpoint tr.s;

  r_cov:coverpoint tr.r;
endgroup
  
covergroup cg_out;
  option.auto_bin_max=10;

  q_cov: coverpoint tr.q;

  qb_cov: coverpoint tr.qbar;


endgroup

 

function new(string name="sr_coverage",uvm_component parent);

  super.new(name,parent);

  item_got_export1= new("item_got_export1", this);

  tr=sr_sequence_item::type_id::create("tr");

  cg_in=new();
  
  cg_out=new();

endfunction

 

  function void write(f_sequence_item t);

   tr=t;

   cg_in.sample();

    $display("input coverage =%0d ",cg_in.get_coverage());
     cg_out.sample();

    $display("output coverage =%0d ",cg_out.get_coverage());

endfunction

endclass
    //-----------------------------------------------------end coverage**************

// -------------------------------------------------------Sequence_item.sv-----------------------------------------------------------
class sr_sequence_item extends uvm_sequence_item;

  //------------ i/p || o/p field declaration-----------------

  rand logic  s;  //i/p
  rand logic  r;

  logic q;        //o/p
  logic qbar;
  
  //---------------- register sr_sequence_item class with factory --------
  `uvm_object_utils_begin(sr_sequence_item) 
     `uvm_field_int( r    ,UVM_ALL_ON)
     `uvm_field_int( s    ,UVM_ALL_ON)
     `uvm_field_int( q    ,UVM_ALL_ON)
     `uvm_field_int( qbar ,UVM_ALL_ON)
  `uvm_object_utils_end
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  function new(string name="sr_sequence_item");
    super.new(name);
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // write DUT inputs here for printing
  function string input2string();
    return($sformatf(" s=%0b  r=%0b",s,r));
  endfunction
  
  // write DUT outputs here for printing
  function string output2string();
    return($sformatf(" q=%0b qbar=%0b", q,qbar));
  endfunction
    
  function string convert2string();
    return($sformatf({input2string(), " || ", output2string()}));
  endfunction
  //----------------------------------------------------------------------------

endclass:sr_sequence_item
// --------------------------------------------------Sequence.sv------------------------------------------------------------------------

/***************************************************
** class name  : sr_sequence
** description : generate random input for DUT
***************************************************/
class sr_sequence extends uvm_sequence#(sr_sequence_item);
  //----------------------------------------------------------------------------
  `uvm_object_utils(sr_sequence)            
  //----------------------------------------------------------------------------

  sr_sequence_item txn;
  int unsigned LOOP=50;

  //----------------------------------------------------------------------------
  function new(string name="sr_sequence");  
    super.new(name);
  endfunction
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  virtual task body();
  repeat(LOOP) begin 
    txn=sr_sequence_item::type_id::create("txn");
    start_item(txn);
    txn.randomize();
    #5;
    finish_item(txn);
  end
  endtask:body
  //----------------------------------------------------------------------------
endclass:sr_sequence

/***************************************************
** class name  : sequence_1
** description : first set and then memory state
***************************************************/
class sequence_1 extends sr_sequence;
  //----------------------------------------------------------------------------   
  `uvm_object_utils(sequence_1)      
  //----------------------------------------------------------------------------
  
  sr_sequence_item txn;
  int unsigned LOOP = 20;
  bit set=1;
  //----------------------------------------------------------------------------
  function new(string name="sequence_1");
      super.new(name);
  endfunction
  //----------------------------------------------------------------------------
  
  //----------------------------------------------------------------------------
  task body();
    for(int i=0;i<LOOP;i++) begin 
    txn=sr_sequence_item::type_id::create("txn");
    start_item(txn);
    txn.randomize()with{txn.s==set;txn.r==0;};
    #5;
    finish_item(txn);
    set=set+1;
  end
  endtask:body
  //----------------------------------------------------------------------------
  
endclass

/***************************************************
** class name  : sequence_2
** description : first reset and then memory state
***************************************************/
class sequence_2 extends sr_sequence;
  //----------------------------------------------------------------------------   
  `uvm_object_utils(sequence_2)      
  //----------------------------------------------------------------------------
  
  sr_sequence_item txn;
  int unsigned LOOP=20;
  bit rst=1;
  
  //----------------------------------------------------------------------------
  function new(string name="sequence_2");
      super.new(name);
  endfunction
  //----------------------------------------------------------------------------
  
  //----------------------------------------------------------------------------
  task body();
    for(int i=0;i<LOOP;i++) begin 
    txn=sr_sequence_item::type_id::create("txn");
    start_item(txn);
      txn.randomize()with{txn.s==0; txn.r==rst;};
    #5;
    finish_item(txn);
    rst=rst+1;
  end
  endtask:body
  //----------------------------------------------------------------------------
  
endclass


/***************************************************
** class name  : sequence_3
** description : first unknown and then memory state
***************************************************/
class sequence_3 extends sr_sequence;
  //----------------------------------------------------------------------------   
  `uvm_object_utils(sequence_3)      
  //----------------------------------------------------------------------------
  
  sr_sequence_item txn;
  int unsigned LOOP=20;
  bit ukn=1;
  //----------------------------------------------------------------------------
  function new(string name="sequence_3");
      super.new(name);
  endfunction
  //----------------------------------------------------------------------------
  
  //----------------------------------------------------------------------------
  task body();
    for(int i=0;i<LOOP;i++) begin 
    txn=sr_sequence_item::type_id::create("txn");
    start_item(txn);
    txn.randomize()with{txn.s==ukn; txn.r==ukn;};
    #5;
    finish_item(txn);
    ukn = ukn + 1;
  end
  endtask:body
  //----------------------------------------------------------------------------
  
endclass
