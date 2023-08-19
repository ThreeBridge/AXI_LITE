`timescale 1ps/1ps
class axi_rw_000 #(parameter BASE_ADDR = 32'h0000_0000) extends test_scenario_base;

    function new( string name );
        super.new(name);
    endfunction

    virtual task execute();
        #100ns;
        AXI_LITE_MASTER.AXI_LITE_WR(BASE_ADDR, 2'b00, 32'h5555_AAAA, 4'hF);
        #100ns;
        AXI_LITE_MASTER.AXI_LITE_RD(BASE_ADDR, 2'b00, 32'h5555_AAAA);
        #100ns;

    endtask

endclass

static axi_rw_000 #(32'h0000_0000) axi_rw_000_0_inst = new("axi_rw_000_0");
static axi_rw_000 #(32'h1000_0000) axi_rw_000_1_inst = new("axi_rw_000_1");
