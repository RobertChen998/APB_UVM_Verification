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
// 1. SETUP 後下一拍必須進 ACCESS
    property p_setup_to_access;
        @(posedge pclk)
        disable iff (!presetn)
        (psel && !penable)
        |=> (psel && penable);
    endproperty

    a_setup_to_access:
        assert property(p_setup_to_access)
        else $error("APB: SETUP did not transition to ACCESS");


    // 2. ACCESS 如果 PREADY=0，控制訊號必須保持穩定
    property p_stable_during_wait;
        @(posedge pclk)
        disable iff (!presetn)
        (psel && penable && !pready)
        |=> $stable({paddr, pwrite, psel, penable, pwdata});
    endproperty

    a_stable_during_wait:
        assert property(p_stable_during_wait)
        else $error("APB: signals changed during wait state");


    // 3. PENABLE 不應該在沒有 PSEL 時拉高
    property p_penable_requires_psel;
        @(posedge pclk)
        disable iff (!presetn)
        penable |-> psel;
    endproperty

    a_penable_requires_psel:
        assert property(p_penable_requires_psel)
        else $error("APB: PENABLE asserted without PSEL");


    // 4. PREADY 只能在 transfer completion 時有意義/拉高
    property p_pready_only_on_completion;
        @(posedge pclk)
        disable iff (!presetn)
        pready |-> (psel && penable);
    endproperty

    a_pready_only_on_completion:
        assert property(p_pready_only_on_completion)
        else $error("APB: PREADY asserted outside completion cycle");

    // 5. PSLVERR 只能在 transfer completion 時有意義/拉高
    // 如果 PSLVERR=1，那現在一定必須是 transaction completion cycle
    property p_pslverr_only_on_completion;
        @(posedge pclk)
        disable iff (!presetn)
        pslverr |-> (psel && penable && pready);
    endproperty

    a_pslverr_only_on_completion:
        assert property(p_pslverr_only_on_completion)
        else $error("APB: PSLVERR asserted outside completion cycle");
    
endinterface
