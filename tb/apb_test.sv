

class apb_test extends uvm_test;
    `uvm_component_utils(apb_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    apb_env env;


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

endclass

class write_test extends apb_test;
    `uvm_component_utils(write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    write_seq wrq;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wrq = write_seq::type_id::create("wrq", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("write_test", $sformatf("Starting write_test sequence"), UVM_LOW)
        wrq.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass: write_test

class read_test extends apb_test;
    `uvm_component_utils(read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    read_seq rdq;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rdq = read_seq::type_id::create("rdq", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        rdq.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass: read_test

class write_read_test extends apb_test;
    `uvm_component_utils(write_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    write_read_seq wr_rd_q;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_rd_q = write_read_seq::type_id::create("wr_rd_q", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wr_rd_q.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass: write_read_test

class writeb_readb_test extends apb_test;
    `uvm_component_utils(writeb_readb_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    writeb_readb_seq wrb_rdb_q;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wrb_rdb_q = writeb_readb_seq::type_id::create("wrb_rdb_q", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wrb_rdb_q.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass

class err_write_test extends apb_test;
    `uvm_component_utils(err_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    err_write_seq err_wr_q;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        err_wr_q = err_write_seq::type_id::create("err_wr_q", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        err_wr_q.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass: err_write_test

class err_read_test extends apb_test;
    `uvm_component_utils(err_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    err_read_seq err_rd_q;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        err_rd_q = err_read_seq::type_id::create("err_rd_q", this);
    endfunction
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        err_rd_q.start(env.agent.sequencer);
        #20
        phase.drop_objection(this);
    endtask: run_phase
endclass: err_read_test

class random_test extends apb_test;
    `uvm_component_utils(random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    random_seq ran_q;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ran_q = random_seq::type_id::create("ran_q", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        ran_q.start(env.agent.sequencer);
        #20;
        phase.drop_objection(this);
    endtask: run_phase
endclass






