class write_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(write_seq)

    function new(string name = "write_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin
            `uvm_create(req)
            req.addr_c.constraint_mode(1);
            req.error_addr_c.constraint_mode(0);
            ok = req.randomize();
            req.t_type = WRITE_t;
            `uvm_send(req)
        end
    endtask

endclass

class read_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(read_seq)

    function new(string name = "read_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin
            `uvm_create(req)
            req.addr_c.constraint_mode(1);
            req.error_addr_c.constraint_mode(0);
            ok = req.randomize();
            req.t_type = READ_t;
            `uvm_send(req)
        end
    endtask

endclass

class write_read_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(write_read_seq)

    function new(string name = "write_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin

            `uvm_create(req)
            req.addr_c.constraint_mode(1);
            req.error_addr_c.constraint_mode(0);
            ok = req.randomize();
            req.t_type = WRITE_t;
            `uvm_send(req)

            ok = req.randomize();
            
            req.t_type = READ_t;
            `uvm_send(req)
        end
    endtask

endclass

// Bulk write, Bulk read
class writeb_readb_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(writeb_readb_seq)

    function new(string name = "writeb_readb_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin

            `uvm_create(req)
            req.addr_c.constraint_mode(1);
            req.error_addr_c.constraint_mode(0);
            ok = req.randomize();
            req.t_type = WRITE_t;
            `uvm_send(req)
        end

        repeat(15) begin
            ok = req.randomize();
            req.t_type = READ_t;
            `uvm_send(req)
        end
    endtask

endclass

class err_write_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(err_write_seq)

    function new(string name = "err_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin
            `uvm_create(req)
            req.addr_c.constraint_mode(0);
            req.error_addr_c.constraint_mode(1);
            ok = req.randomize();
            req.t_type = WRITE_t;
            `uvm_send(req)
        end
    endtask

endclass

class err_read_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(err_read_seq)

    function new(string name = "err_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(15) begin
            `uvm_create(req)
            req.addr_c.constraint_mode(0);
            req.error_addr_c.constraint_mode(1);
            ok = req.randomize();
            req.t_type = READ_t;
            `uvm_send(req)
        end
    endtask


endclass

class random_seq extends uvm_sequence #(transaction);
    `uvm_object_utils(random_seq)

    function new(string name = "random_seq");
        super.new(name);
    endfunction

    virtual task body();
        int ok;
        repeat(5000) begin
            `uvm_create(req)
            req.addr_rand_c.constraint_mode(1);
            req.error_addr_c.constraint_mode(0);
            req.addr_c.constraint_mode(0);
            ok = req.randomize() with { t_type dist {RESET_t := 1, WRITE_t := 60, READ_t := 39 }; };
            `uvm_send(req)
        end
    endtask
endclass
