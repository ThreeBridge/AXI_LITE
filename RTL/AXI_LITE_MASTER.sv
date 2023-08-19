//-----------------------------------------------------------------------------
// Title         : AXI LITE MASTER MODEL
// Project       : 
//-----------------------------------------------------------------------------
// File          : AXI_LITE_MASTER.sv
// Author        :
// Created       : 
// Last modified :
//-----------------------------------------------------------------------------
// Description   :
//-----------------------------------------------------------------------------

module AXI_LITE_MASTER#(
    parameter                                   P_ADDR_WIDTH    = 32    ,   //
    parameter                                   P_DATA_WIDTH    = 32        //
)(
    input   logic                               CLK                     ,   //
    input   logic                               RST                     ,   //
    // AW
    output  logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_AWADDR         ,   //
    output  logic                     [ 1: 0]   AXI_LITE_AWPROT         ,   //
    output  logic                               AXI_LITE_AWVALID        ,   //
    input   logic                               AXI_LITE_AWREADY        ,   //
    // W
    output  logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_WDATA          ,   //
    output  logic   [P_DATA_WIDTH / 8 - 1: 0]   AXI_LITE_WSTRB          ,   //
    output  logic                               AXI_LITE_WVALID         ,   //
    input   logic                               AXI_LITE_WREADY         ,   //
    // B
    input   logic                     [ 1: 0]   AXI_LITE_BRESP          ,   //
    input   logic                               AXI_LITE_BVALID         ,   //
    output  logic                               AXI_LITE_BREADY         ,   //
    // AR
    output  logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_ARADDR         ,   //
    output  logic                     [ 1: 0]   AXI_LITE_ARPROT         ,   //
    output  logic                               AXI_LITE_ARVALID        ,   //
    input   logic                               AXI_LITE_ARREADY        ,   //
    // R
    input   logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_RDATA          ,   //
    input   logic                     [ 1: 0]   AXI_LITE_RRESP          ,   //
    input   logic                               AXI_LITE_RVALID         ,   //
    output  logic                               AXI_LITE_RREADY             //
);
    event   e_aw, e_w, e_b, e_ar, e_r;

    int                             LOG_HANDLE                          ;
    logic                           err_flag            = 0             ;

    int                             axi_b_force_ready   = 0             ;
    int                             axi_r_force_ready   = 0             ;
    int                             axi_b_delay         = 1             ;
    int                             axi_r_delay         = 1             ;

    task AXI_LITE_WR(input logic [P_ADDR_WIDTH-1:0] addr, input logic [1:0] prot, input logic [P_DATA_WIDTH-1:0] data, input logic [P_DATA_WIDTH/8-1:0] strb);
        fork
            begin   // AW
                $display($time, "ps AXI_LITE WRITE : ADDR=0x%08h, WDATA=0x%08h STRB=0b%04b", addr, data, strb);
                @(posedge CLK);
                AXI_LITE_AWADDR     = addr;
                AXI_LITE_AWPROT     = prot;
                AXI_LITE_AWVALID    = 1;
                wait(AXI_LITE_AWREADY) @(posedge CLK);
                AXI_LITE_AWADDR     = '0;
                AXI_LITE_AWPROT     = '0;
                AXI_LITE_AWVALID    = 0;
            end
            begin   // W
                AXI_LITE_WDATA      = data;
                AXI_LITE_WSTRB      = strb;
                AXI_LITE_WVALID     = 1;
                wait(AXI_LITE_WREADY) @(posedge CLK);
                AXI_LITE_WDATA      = '0;
                AXI_LITE_WSTRB      = '0;
                AXI_LITE_WVALID     = 1;
            end
        join
        @(e_b);
    endtask

    task get_req_b();
        forever begin
            @(posedge CLK) #1;
            if( axi_b_force_ready )begin
                AXI_LITE_BREADY     = 1;
            end else begin
                AXI_LITE_BREADY     = 0;
                if( AXI_LITE_BVALID )begin
                    repeat(axi_b_delay) @(posedge CLK);
                    AXI_LITE_BREADY = 1;
                    -> e_b;
                    @(posedge CLK);
                    AXI_LITE_BREADY = 0;
                end
            end
        end
    endtask

    task AXI_LITE_RD(input logic [P_ADDR_WIDTH-1:0] addr, input logic [1:0] prot, input logic [P_DATA_WIDTH-1:0] exp_data);
        err_flag            = 0;
        @(posedge CLK);
        AXI_LITE_ARADDR     = addr;
        AXI_LITE_ARPROT     = prot;
        AXI_LITE_ARVALID    = 1;
        wait(AXI_LITE_ARREADY) @(posedge CLK);
        AXI_LITE_ARADDR     = '0;
        AXI_LITE_ARPROT     = '0;
        AXI_LITE_ARVALID    = 0;
        @(e_r);
        if(AXI_LITE_RDATA === exp_data)begin
            $display($time, "ps AXI_LITE  READ : OK, ADDR=0x%08h, EXP=0x%08h, RDATA=0x%08h", addr, exp_data, AXI_LITE_RDATA);
        end else begin
            $display($time, "ps AXI_LITE  READ : NG, ADDR=0x%08h, EXP=0x%08h, RDATA=0x%08h", addr, exp_data, AXI_LITE_RDATA);
            err_flag        = 1;
        end
        @(posedge CLK);
        err_flag            = 0;
    endtask

    task get_resp_r();
        forever begin
            @(posedge CLK) #1;
            if( axi_r_force_ready )begin
                AXI_LITE_RREADY = 1;
            end else begin
                AXI_LITE_RREADY = 0;
                if( AXI_LITE_RVALID )begin
                    repeat(axi_r_delay) @(posedge CLK);
                    AXI_LITE_RREADY = 1;
                    -> e_r;
                    @(posedge CLK);
                    AXI_LITE_RREADY = 0;
                end
            end
        end
    endtask

    task bus_reset();
        AXI_LITE_AWADDR     = 0;
        AXI_LITE_AWPROT     = 0;
        AXI_LITE_AWVALID    = 0;
        AXI_LITE_WDATA      = 0;
        AXI_LITE_WSTRB      = 0;
        AXI_LITE_WVALID     = 0;
        AXI_LITE_BREADY     = 0;
        AXI_LITE_ARADDR     = 0;
        AXI_LITE_ARPROT     = 0;
        AXI_LITE_ARVALID    = 0;
        AXI_LITE_RREADY     = 0;
    endtask

    initial begin
        forever begin
            bus_reset;
            if( RST ) @(negedge RST);
            fork
                get_req_b   ;
                get_resp_r  ;
            join_none
            @(posedge RST);
            disable fork;
        end
    end

endmodule