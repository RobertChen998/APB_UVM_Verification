class apb_env extends uvm_env;
    `uvm_component_utils(apb_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    apb_agent agent;
    apb_scoreboard scoreboard;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_agent::type_id::create("agent", this);
        scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        agent.monitor.item_collected_port.connect(scoreboard.sboard_imp);
    endfunction
endclass: apb_env