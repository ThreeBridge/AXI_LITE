interface #(
    parameter                           P_ADDR_WIDTH    = 32    ,   //
    parameter                           P_DATA_WIDTH    = 32        //
) axi_lite_if ();
    
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

    modport mst_port(output AXI_LITE_AWADDR, AXI_LITE_AWPROT, AXI_LITE_AWVALID, AXI_LITE_WDATA, AXI_LITE_WSTRB, AXI_LITE_WVALID, AXI_LITE_BREADY, AXI_LITE_ARADDR, AXI_LITE_ARPROT, AXI_LITE_ARVALID, AXI_LITE_RREADY,
                     input  AXI_LITE_AWREADY, AXI_LITE_WREADY, AXI_LITE_BRESP, AXI_LITE_BVALID, AXI_LITE_ARREADY, AXI_LITE_RDATA , AXI_LITE_RRESP, AXI_LITE_RVALID );
    modport slv_port(output AXI_LITE_AWREADY, AXI_LITE_WREADY, AXI_LITE_BRESP, AXI_LITE_BVALID, AXI_LITE_ARREADY, AXI_LITE_RDATA , AXI_LITE_RRESP, AXI_LITE_RVALID,
                     input  AXI_LITE_AWADDR, AXI_LITE_AWPROT, AXI_LITE_AWVALID, AXI_LITE_WDATA, AXI_LITE_WSTRB, AXI_LITE_WVALID, AXI_LITE_BREADY, AXI_LITE_ARADDR, AXI_LITE_ARPROT, AXI_LITE_ARVALID, AXI_LITE_RREADY);

endinterface //axi_lite_if