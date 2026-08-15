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
    IDLE = 2'b00,
    SETUP = 2'b01,
    ACCESS = 2'b10
    } state_t;

    logic [31:0] mem_w [32];
    logic [31:0] mem_r [32];
    state_t state_w, state_r;


    // Next state logic
    always_comb begin
        state_w = state_r;
        pready = 1'b0;
        pslverr = 1'b0;
        prdata = 32'b0; 
        mem_w = mem_r;
        case(state_r)
            IDLE: begin
                state_w = SETUP;
            end
            SETUP: begin
                if(psel) begin
                    state_w = ACCESS;
                end
            end
            ACCESS: begin
                pready = 1'b1;
                if(penable) begin
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
            default: begin
                state_w = IDLE;
            end
        endcase

    end

    always_ff @(posedge pclk or negedge presetn) begin
        if(!presetn) begin
            state_r <= IDLE;
            for(int i=0 ; i<32; i++) begin
                mem_r[i] <= 32'b0;
            end
        end
        else begin
            state_r <= state_w;
            for(int i=0 ; i<32; i++) begin
                mem_r[i] <= mem_w[i];
            end
        end
    end

endmodule