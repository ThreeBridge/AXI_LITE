`timescale 1ps/1ps
module tb ();

    parameter                           P_CLK_TIME      = 10ns  ;
    parameter                           P_ADDR_WIDTH    = 32    ;   //
    parameter                           P_DATA_WIDTH    = 32    ;   //

    logic                               CLK                     ;   //
    logic                               RST                     ;   //
    // AW
    logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_AWADDR         ;   //
    logic                     [ 1: 0]   AXI_LITE_AWPROT         ;   //
    logic                               AXI_LITE_AWVALID        ;   //
    logic                               AXI_LITE_AWREADY        ;   //
    // W
    logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_WDATA          ;   //
    logic   [P_DATA_WIDTH / 8 - 1: 0]   AXI_LITE_WSTRB          ;   //
    logic                               AXI_LITE_WVALID         ;   //
    logic                               AXI_LITE_WREADY         ;   //
    // B
    logic                     [ 1: 0]   AXI_LITE_BRESP          ;   //
    logic                               AXI_LITE_BVALID         ;   //
    logic                               AXI_LITE_BREADY         ;   //
    // AR
    logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_ARADDR         ;   //
    logic                     [ 1: 0]   AXI_LITE_ARPROT         ;   //
    logic                               AXI_LITE_ARVALID        ;   //
    logic                               AXI_LITE_ARREADY        ;   //
    // R
    logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_RDATA          ;   //
    logic                     [ 1: 0]   AXI_LITE_RRESP          ;   //
    logic                               AXI_LITE_RVALID         ;   //
    logic                               AXI_LITE_RREADY         ;   //

    //
    bit                                 clk                     ;
    bit                                 rst                     ;

    initial forever begin
        #(P_CLK_TIME) clk   = ~clk;
    end

    initial begin
        #10;
        rst = 1;
        #100;
        rst = 0;
    end

    assign CLK = clk;
    assign RST = rst;

    // DUT
    AXI_LITE_MASTER #(
        .P_ADDR_WIDTH   ( P_ADDR_WIDTH  ),
        .P_DATA_WIDTH   ( P_DATA_WIDTH  )
    ) AXI_LITE_MASTER   ( .* );

    AXI_LITE_SLAVE #(
        .P_ADDR_WIDTH   ( P_ADDR_WIDTH  ),
        .P_DATA_WIDTH   ( P_DATA_WIDTH  )
    ) AXI_LITE_SLAVE    ( .* );

    `include "test_list.sv"

    test_scenario_base ts = new();

    initial begin
        ts.run_tests();
        #10;
        $finish;
    end

endmodule