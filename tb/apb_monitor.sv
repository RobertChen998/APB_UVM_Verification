class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor);

    uvm_analysis_port#(transaction) item_collected_port;

    virtual interface apb_if vif;
    transaction tr;

    covergroup apb_monitor_cg;

        // Coverpoint for address
        CP_addr: coverpoint tr.PADDR {
            bins VALID[] = {[0:31]};
            bins ILLEGAL[] = {[32:63]};
        }

        CP_type: coverpoint tr.t_type {
            bins WRITE = {WRITE_t};
            bins READ = {READ_t};
        }

        CP_cross_addr_type: cross CP_addr, CP_type;

    endgroup: apb_monitor_cg
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        apb_monitor_cg = new();
        apb_monitor_cg.set_inst_name({get_full_name(), ".apb_monitor_cg"});
    endfunction

    function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %0s", get_full_name()));
        end
        else begin
            `uvm_info("Monitor", $sformatf("Virtual interface is set for: %0s", get_full_name()), UVM_LOW)
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.pclk);
            tr = transaction::type_id::create("tr", this);
            if(!vif.presetn) begin
                tr.t_type = RESET_t;
            end
            else if(vif.pwrite) begin
                //@(posedge vif.pready);
                // posedge 完立刻抓會有問題，會抓不到同一cycle 的 PRDATA
                do begin
                    @(posedge vif.pclk);
                end
                while (vif.pready !== 1'b1);
                tr.t_type = WRITE_t;
                tr.PADDR = vif.paddr;
                tr.PWDATA = vif.pwdata;
                tr.PSLVERR = vif.pslverr;
                `uvm_info("Monitor: ", $sformatf("Transaction: %0s, addr:%0d, wdata:%0d , slverr: %0d", tr.t_type.name(), tr.PADDR, tr.PWDATA, tr.PSLVERR), UVM_LOW)
            end
            else if(!vif.pwrite) begin
                //@(posedge vif.pready);
                // posedge 完立刻抓會有問題，會抓不到同一cycle 的 PRDATA
                do begin
                    @(posedge vif.pclk);
                end
                while (vif.pready !== 1'b1);
                tr.t_type = READ_t;
                tr.PADDR = vif.paddr;
                tr.PRDATA = vif.prdata;
                tr.PSLVERR = vif.pslverr;
                `uvm_info("Monitor: ", $sformatf("Transaction: %0s, addr:%0d, rdata:%0d , slverr: %0d", tr.t_type.name(), tr.PADDR, tr.PRDATA, tr.PSLVERR),UVM_LOW)
            end
            item_collected_port.write(tr);
            apb_monitor_cg.sample();
        end

    endtask: run_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: APB Monitor Coverage: %0d", apb_monitor_cg.get_inst_coverage()), UVM_LOW)
    endfunction: report_phase

endclass: apb_monitor