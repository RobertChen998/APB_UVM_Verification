typedef enum logic [1:0] {
    RESET_t = 2'b00,
    WRITE_t = 2'b01,
    READ_t = 2'b10
} tran_type;

class transaction extends uvm_sequence_item;

    rand tran_type t_type;
    rand logic [31:0] PWDATA;
    rand logic [31:0] PADDR;

    logic [31:0] PRDATA;
    logic PREADY;
    logic PSLVERR;

    // For all other test
    constraint addr_c { PADDR < 32;}
    constraint error_addr_c {PADDR >= 32;}

    // For random_test
    constraint addr_rand_c {
        PADDR dist{
            [0:30] := 50,
            31 := 10,
            32 := 10,
            [33:63] := 30
        };
    }

    `uvm_object_utils_begin(transaction)
    `uvm_field_enum(tran_type, t_type, UVM_ALL_ON)
    `uvm_field_int(PWDATA, UVM_ALL_ON)
    `uvm_field_int(PADDR, UVM_ALL_ON)
    `uvm_field_int(PRDATA, UVM_ALL_ON)
    `uvm_field_int(PREADY, UVM_ALL_ON)
    `uvm_field_int(PSLVERR, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "transaction");
        super.new(name);
    endfunction

endclass