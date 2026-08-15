class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent);

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    apb_monitor monitor;
    apb_driver driver;
    apb_sequencer sequencer;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = apb_monitor::type_id::create("monitor", this);
        driver = apb_driver::type_id::create("driver", this);
        sequencer = apb_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass: apb_agent