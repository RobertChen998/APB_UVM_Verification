class apb_scoreboard extends uvm_scoreboard;

`uvm_component_utils(apb_scoreboard)

uvm_analysis_imp #(transaction, apb_scoreboard) sboard_imp;
bit [31:0] mem[32] = '{default:0};

function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sboard_imp = new("sboard_imp",this);
endfunction

int error_cnt=0;
int total_tested_case=0;

virtual function void write(transaction tr);
    total_tested_case++;
    if(tr.t_type == RESET_t) begin
        `uvm_info("Scoreboard", "RESET detected clearing memory", UVM_LOW);
        for(int i=0; i<32; i++) begin
            mem[i] = 0;
        end
    end
    else if (tr.t_type == WRITE_t) begin

        if (tr.PADDR < 32) begin
            // Legal address
            if (tr.PSLVERR) begin
                `uvm_error("Scoreboard",
                    $sformatf(
                        "WRITE unexpected PSLVERR! PADDR=%0d PWDATA=%0d",
                        tr.PADDR, tr.PWDATA
                    ))
                error_cnt++;
            end
            else begin
                mem[tr.PADDR] = tr.PWDATA;
            end
        end

        else begin
            // Illegal address
            if (!tr.PSLVERR) begin
                `uvm_error("Scoreboard",
                    $sformatf(
                        "WRITE missing PSLVERR for illegal address! PADDR=%0d",
                        tr.PADDR
                    ))
                error_cnt++;
            end
        end
    end
    
    else if (tr.t_type == READ_t) begin

        if (tr.PADDR < 32) begin
            // Legal address
            if (tr.PSLVERR) begin
                `uvm_error("Scoreboard",
                    $sformatf(
                        "READ unexpected PSLVERR! PADDR=%0d",
                        tr.PADDR
                    ))
                error_cnt++;
            end
            else begin
                if (mem[tr.PADDR] == tr.PRDATA) begin
                    `uvm_info("Scoreboard", "READ SUCCESSFUL!", UVM_LOW)
                end
                else begin
                    `uvm_error("Scoreboard",
                        $sformatf(
                            "READ data mismatch! PADDR=%0d Expect=%0d Get=%0d",
                            tr.PADDR,
                            mem[tr.PADDR],
                            tr.PRDATA
                        ))
                    error_cnt++;
                end
            end
        end

        else begin
            // Illegal address
            if (!tr.PSLVERR) begin
                `uvm_error("Scoreboard",
                    $sformatf(
                        "READ missing PSLVERR for illegal address! PADDR=%0d",
                        tr.PADDR
                    ))
                error_cnt++;
            end
        end
    end
endfunction

function void report_phase(uvm_phase phase);
    `uvm_info("Scoreboard", $sformatf("Total tested cases: %0d", total_tested_case), UVM_LOW)
    `uvm_info("Scoreboard", $sformatf("Total Errors: %0d", error_cnt), UVM_LOW)
endfunction
endclass: apb_scoreboard