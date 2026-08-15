interface apb_if ();
    logic pclk;
    logic presetn;
    logic [31:0] paddr;
    logic pwrite;
    logic psel;
    logic penable;
    logic [31:0] pwdata;
    logic pready;
    logic pslverr;
    logic [31:0] prdata;

    // 1. Setup to Access transition: When PSEL is asserted and PENABLE is deasserted, the next cycle should transition to Access state with PENABLE asserted.
    //    During this transition, the signals PADDR and PWRITE should remain stable.
    //    If PWRITE is asserted, then PWDATA should also remain stable during this transition.
    property p_stable_setup_to_access;
        @(posedge pclk)
        disable iff (!presetn)
        (psel && !penable)
        |=> (psel && penable &&
            $stable({paddr, pwrite}) && (!pwrite || $stable(pwdata)));
    endproperty

    a_stable_setup_to_access:
        assert property(p_stable_setup_to_access)
        else $error("APB: signals changed during setup to access");

    // 2. Access phase should follow Setup phase: When PENABLE is asserted, it indicates in the previous cycle, PSEL should have been asserted and PENABLE should have been deasserted.
    property p_access_follows_setup;
        @(posedge pclk)
        disable iff (!presetn)
        $rose(penable) |-> $past(psel && !penable);
    endproperty

    a_access_follows_setup:
        assert property(p_access_follows_setup)
        else $error("APB: Access phase did not follow Setup phase");

    // 3. When PREADY is not asserted yet, the signals PADDR, PWRITE, PSEL, PENABLE, and PWDATA should remain stable until pready is asserted.
    property p_stable_during_wait;
        @(posedge pclk)
        disable iff (!presetn)
        (psel && penable && !pready)
        |=> $stable({paddr, pwrite, psel, penable, pwdata});
    endproperty

    a_stable_during_wait:
        assert property(p_stable_during_wait)
        else $error("APB: signals changed during wait state");


    // 4. When PSLVERR is asserted, it indicates the completion of the current transfer. In current cycle, PSEL and PENABLE should be asserted.

    property p_pslverr_only_on_completion;
        @(posedge pclk)
        disable iff (!presetn)
        pslverr |-> (psel && penable && pready);
    endproperty

    a_pslverr_only_on_completion:
        assert property(p_pslverr_only_on_completion)
        else $error("APB: PSLVERR asserted outside completion cycle");

    // 5. After a transfer is completed, PENABLE should be deasserted.
    property p_exit_access_after_completion;
        @(posedge pclk)
        disable iff (!presetn)
        (psel && penable && pready)
        |=> !penable;
    endproperty

    a_exit_access_after_completion:
        assert property(p_exit_access_after_completion)
        else $error("APB: PENABLE remained asserted after transfer completion");
    
endinterface

