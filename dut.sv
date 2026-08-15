module apb_slave (
  input pclk,
  input presetn,
  input [31:0] paddr,
  input pwrite,
  input psel,
  input penable,
  input [31:0] pwdata,
  output logic pready,
  output logic pslverr,
  output logic [31:0] prdata
);
    // State encoding
    typedef enum logic [1:0]{
    SETUP = 2'b01,
    ACCESS = 2'b10
    } state_t;

    logic [31:0] mem_w [32];
    logic [31:0] mem_r [32];
    state_t state_w, state_r;

    parameter int MAX_WAIT_CYCLES = 5;

    int unsigned wait_cycles;


    // Next state logic
    always_comb begin
        state_w = state_r;
        pready = 1'b1;
        pslverr = 1'b0;
        prdata = 32'b0; 
        mem_w = mem_r;
        case(state_r)
            SETUP: begin
                if(psel) begin
                    state_w = ACCESS;
                end
            end
            ACCESS: begin
                if(psel &&penable) begin
                    if(wait_cycles > 0) begin
                        pready = 1'b0;
                        state_w = ACCESS;
                    end
                    else begin
                        pready = 1'b1;
                        state_w = SETUP;
                        if(pwrite) begin
                            if(paddr <32) begin
                                mem_w[paddr[4:0]] = pwdata;
                            end
                            else begin
                                pslverr = 1'b1;
                            end
                        end
                        else begin
                            if(paddr <32) begin
                                prdata = mem_r[paddr[4:0]];
                            end
                            else begin
                                pslverr = 1'b1;
                                prdata = 32'hxxxx_xxxx;
                            end
                        end
                    end
                end
            end
        endcase

    end

    always_ff @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
            state_r <= SETUP;
            for(int i=0 ; i<32; i++) begin
                mem_r[i] <= 32'b0;
            end
            wait_cycles <= 0;
        end
        else begin
            state_r <= state_w;
            for(int i=0 ; i<32; i++) begin
                mem_r[i] <= mem_w[i];
            end
            if(state_r == SETUP && psel ) begin
                wait_cycles <= $urandom_range(0, MAX_WAIT_CYCLES);
            end
            else if(state_r == ACCESS && psel && penable && wait_cycles > 0) begin
                wait_cycles <= wait_cycles - 1;
            end
        end
    end

endmodule