class apb_driver extends uvm_driver #(transaction);
    `uvm_component_utils(apb_driver)
    virtual interface apb_if vif;

    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %0s", get_full_name()));
        end
        else begin
            `uvm_info("Driver", $sformatf("Virtual interface is set for: %0s", get_full_name()), UVM_LOW)
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        get_and_drive();
    endtask: run_phase

    task reset_signals();
        vif.presetn <= 1'b0;
        vif.psel <= 0;
        vif.penable <= 0;
        vif.pwrite <= 0;
        vif.paddr <= 0;
        vif.pwdata <= 0;
        `uvm_info("Driver", "Reset", UVM_LOW)
        @(posedge vif.pclk);
    endtask: reset_signals

    task get_and_drive();
        forever begin
            seq_item_port.get_next_item(req);

            if(req.t_type == RESET_t) begin
                vif.presetn <= 1'b0;
                `uvm_info("Driver", $sformatf("Here is the Transaction: %0s, addr:%0d, wdata:%0d ,rdata: %0d, slverr: %0d", req.t_type.name(), req.PADDR, req.PWDATA, req.PRDATA, req.PSLVERR), UVM_LOW)
                @(posedge vif.pclk);
                vif.presetn <= 1'b1;
                `uvm_info("Driver", $sformatf("Transaction: %0s, addr:%0d, wdata:%0d ,rdata: %0d, slverr: %0d", req.t_type.name(), req.PADDR, req.PWDATA, req.PRDATA, req.PSLVERR), UVM_LOW)
            end
            else if(req.t_type == WRITE_t) begin
                vif.presetn <= 1'b1;
                vif.paddr <= req.PADDR;
                vif.pwrite <= 1'b1;
                vif.psel <= 1'b1;
                vif.pwdata <= req.PWDATA;
                @(posedge vif.pclk);
                vif.penable <= 1'b1;
                do begin
                    @(posedge vif.pclk);
                end
                while (vif.pready !== 1'b1);
                req.PSLVERR = vif.pslverr;
                `uvm_info("Driver", $sformatf("Transaction: %0s, addr:%0d, wdata:%0d ,rdata: %0d, slverr: %0d", req.t_type.name(), req.PADDR, req.PWDATA, req.PRDATA, req.PSLVERR), UVM_LOW)
                vif.penable <= 1'b0;
                vif.psel <= 1'b0;
            end
            else if(req.t_type == READ_t) begin
                vif.presetn <= 1'b1;
                vif.paddr <= req.PADDR;
                vif.pwrite <= 1'b0;
                vif.psel <= 1'b1;
                @(posedge vif.pclk);
                vif.penable <= 1'b1;
                do begin
                    @(posedge vif.pclk);
                end
                while (vif.pready !== 1'b1);
                req.PRDATA = vif.prdata;
                req.PSLVERR = vif.pslverr;
                `uvm_info("Driver", $sformatf("Transaction: %0s, addr:%0d, wdata:%0d ,rdata: %0d, slverr: %0d", req.t_type.name(), req.PADDR, req.PWDATA, req.PRDATA, req.PSLVERR), UVM_LOW)
                vif.penable <= 1'b0;
                vif.psel <= 1'b0;
                
            end
            else begin
                `uvm_info("Driver", $sformatf("Unexpected Transaction: %0s", req.t_type.name()), UVM_LOW)
            end
            seq_item_port.item_done();
        end
    endtask: get_and_drive

endclass : apb_driver