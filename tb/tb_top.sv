module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "transaction.sv"
    `include "sequence.sv"
    `include "apb_if.sv"
    `include "apb_sequencer.sv"
    `include "apb_driver.sv"
    `include "apb_monitor.sv"
    `include "apb_agent.sv"
    `include "apb_scoreboard.sv"
    `include "apb_env.sv"
    `include "apb_test.sv"

    apb_if vif();
    apb_slave dut(
        .pclk(vif.pclk),
        .presetn(vif.presetn),
        .paddr(vif.paddr),
        .pwrite(vif.pwrite),
        .psel(vif.psel),
        .penable(vif.penable),
        .pwdata(vif.pwdata),
        .pready(vif.pready),
        .prdata(vif.prdata),
        .pslverr(vif.pslverr)
    );

    // initial begin
    //     vif.pclk<=0;
    // end

    // always #10 vif.pclk <= ~vif.pclk;

    initial begin
    vif.pclk = 0;

    forever begin
        #10;
        vif.pclk = ~vif.pclk;
    end
end

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "*.env.agent.*", "vif", vif);
        run_test("random_test");
    end
endmodule