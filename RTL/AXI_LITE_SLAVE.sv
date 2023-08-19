//-----------------------------------------------------------------------------
// Title         : AXI LITE SLAVE MODEL
// Project       : 
//-----------------------------------------------------------------------------
// File          : AXI_LITE_SLAVE.sv
// Author        :
// Created       : 
// Last modified :
//-----------------------------------------------------------------------------
// Description   :
//-----------------------------------------------------------------------------

module AXI_LITE_SLAVE#(
    parameter                                   P_ADDR_WIDTH    = 32    ,   //
    parameter                                   P_DATA_WIDTH    = 32        //
)(
    input   logic                               CLK                     ,   //
    input   logic                               RST                     ,   //
    // AW
    input   logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_AWADDR         ,   //
    input   logic                     [ 1: 0]   AXI_LITE_AWPROT         ,   //
    input   logic                               AXI_LITE_AWVALID        ,   //
    output  logic                               AXI_LITE_AWREADY        ,   //
    // W
    input   logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_WDATA          ,   //
    input   logic   [P_DATA_WIDTH / 8 - 1: 0]   AXI_LITE_WSTRB          ,   //
    input   logic                               AXI_LITE_WVALID         ,   //
    output  logic                               AXI_LITE_WREADY         ,   //
    // B
    output  logic                     [ 1: 0]   AXI_LITE_BRESP          ,   //
    output  logic                               AXI_LITE_BVALID         ,   //
    input   logic                               AXI_LITE_BREADY         ,   //
    // AR
    input   logic   [P_ADDR_WIDTH     - 1: 0]   AXI_LITE_ARADDR         ,   //
    input   logic                     [ 1: 0]   AXI_LITE_ARPROT         ,   //
    input   logic                               AXI_LITE_ARVALID        ,   //
    output  logic                               AXI_LITE_ARREADY        ,   //
    // R
    output  logic   [P_DATA_WIDTH     - 1: 0]   AXI_LITE_RDATA          ,   //
    output  logic                     [ 1: 0]   AXI_LITE_RRESP          ,   //
    output  logic                               AXI_LITE_RVALID         ,   //
    input   logic                               AXI_LITE_RREADY             //
);
    event   e_aw, e_w, e_b, e_ar, e_r;

    logic   [P_ADDR_WIDTH - 1 : 0]  awaddr_q    [$]             ;
    logic   [P_DATA_WIDTH - 1 : 0]  wdata_q     [$]             ;
    logic   [P_ADDR_WIDTH - 1 : 0]  araddr_q    [$]             ;
    logic   [P_DATA_WIDTH - 1 : 0]  mem         [int unsigned]  ;

    int                             axi_aw_force_ready  = 0     ;
    int                             axi_aw_delay        = 1     ;
    int                             axi_w_force_ready   = 0     ;
    int                             axi_w_delay         = 1     ;
    int                             axi_b_delay         = 1     ;
    int                             axi_ar_force_ready  = 0     ;
    int                             axi_ar_delay        = 1     ;
    int                             axi_r_delay         = 1     ;

    task ready_allset(
        input int    cyc
    );
        begin
            if (cyc == -1) begin
                axi_aw_force_ready  = 1     ;
                axi_w_force_ready   = 1     ;
                axi_ar_force_ready  = 1     ;
            end
            else begin
                axi_aw_force_ready  = 0     ;
                axi_w_force_ready   = 0     ;
                axi_ar_force_ready  = 0     ;
                axi_aw_delay        = cyc   ;
                axi_w_delay         = cyc   ;
                axi_ar_delay        = cyc   ;
            end
        end
    endtask

    task resp_allset(
        input int    cyc
    );
        begin
            axi_b_delay         = cyc   ;
            axi_r_delay         = cyc   ;
        end
    endtask

    task get_req_aw();
        fork
            forever begin
                @(posedge CLK) #1;
                if( axi_aw_force_ready )begin
                    AXI_LITE_AWREADY = 1;
                end else begin
                    AXI_LITE_AWREADY = 0;
                    if( AXI_LITE_AWVALID )begin
                        repeat(axi_aw_delay) @(posedge CLK);
                        AXI_LITE_AWREADY = 1;
                        @(posedge CLK);
                        AXI_LITE_AWREADY = 0;
                    end
                end
            end
            forever begin
                @(negedge CLK);
                if( AXI_LITE_AWVALID & AXI_LITE_AWREADY )begin
                    awaddr_q.push_back(AXI_LITE_AWADDR);
                    -> e_aw;
                end
            end
        join_none
    endtask

    task get_req_w();
        bit [P_DATA_WIDTH - 1: 0] this_data;
        fork
            forever begin
                @(posedge CLK) #1;
                if( axi_w_force_ready )begin
                    AXI_LITE_WREADY = 1;
                end else begin
                    AXI_LITE_WREADY = 0;
                    if( AXI_LITE_WVALID )begin
                        repeat(axi_w_delay) @(posedge CLK);
                        AXI_LITE_WREADY = 1;
                        @(posedge CLK);
                        AXI_LITE_WREADY = 0;
                    end
                end
            end
            forever begin
                @(negedge CLK);
                if( AXI_LITE_WVALID & AXI_LITE_WREADY )begin
                    for( int byte_index = 0; byte_index < P_DATA_WIDTH / 8; byte_index++ )begin
                        if( AXI_LITE_WSTRB[byte_index] )begin
                            this_data[( byte_index * 8 ) +: 8] = AXI_LITE_WDATA[( byte_index * 8 ) +: 8];
                        end else begin
                            this_data[( byte_index * 8 ) +: 8] = 8'h00;
                        end
                    end
                    wdata_q.push_back(this_data);
                    -> e_w;
                end
            end
        join_none
    endtask

    task write_mem();
        bit [P_ADDR_WIDTH - 1: 0] this_addr;
        bit [P_DATA_WIDTH - 1: 0] this_data;
        forever begin
            wait( awaddr_q.size() && wdata_q.size() );
            this_addr = awaddr_q.pop_front();
            this_data = wdata_q.pop_front();
            mem[this_addr] = this_data;
            write_resp();
        end
    endtask

    task write_resp();
        repeat(axi_b_delay) @(posedge CLK);
        AXI_LITE_BRESP   = 2'b00;
        AXI_LITE_BVALID  = 1;
        @(posedge CLK);
        while( !AXI_LITE_BREADY ) @(posedge CLK);
        AXI_LITE_BVALID  = 0;
        -> e_b;
    endtask

    task get_req_ar();
        fork
            forever begin
                @(posedge CLK) #1;
                if( axi_ar_force_ready )begin
                    AXI_LITE_ARREADY = 1;
                end else begin
                    AXI_LITE_ARREADY = 0;
                    if( AXI_LITE_ARVALID )begin
                        repeat(axi_ar_delay) @(posedge CLK);
                        AXI_LITE_ARREADY = 1;
                        @(posedge CLK);
                        AXI_LITE_ARREADY = 0;
                    end
                end
            end
            forever begin
                @(negedge CLK);
                if( AXI_LITE_ARVALID & AXI_LITE_ARREADY )begin
                    araddr_q.push_back(AXI_LITE_ARADDR);
                    -> e_ar;
                end
            end
        join_none
    endtask

    task read_mem();
        bit [P_ADDR_WIDTH - 1: 0] this_addr;
        bit [P_DATA_WIDTH - 1: 0] this_data;
        bit               [ 1: 0] this_resp;
        forever begin
            wait( araddr_q.size() );
            this_addr = araddr_q.pop_front();
            if( mem.exists(this_addr) )begin
                this_data = mem[this_addr];
                this_resp = 2'b00;
            end else begin
                $display("[%10d] addr=%08xxh is not exist", $time, this_addr);
                this_data = {P_DATA_WIDTH{1'b0}};
                this_resp = 2'b01;
            end
            read_resp( this_data, this_resp );
        end
    endtask

    task read_resp( bit [P_DATA_WIDTH - 1: 0] idata, bit [ 1: 0] iresp );
        repeat( axi_r_delay ) @(posedge CLK);
        AXI_LITE_RDATA   = idata;
        AXI_LITE_RRESP   = iresp;
        AXI_LITE_RVALID  = 1;
        @(posedge CLK);
        while( !AXI_LITE_RREADY ) @(posedge CLK);
        AXI_LITE_RVALID  = 0;
        -> e_r;
    endtask

    task bus_reset();
        AXI_LITE_AWREADY = 0;
        AXI_LITE_WREADY  = 0;
        AXI_LITE_BRESP   = 0;
        AXI_LITE_BVALID  = 0;
        AXI_LITE_ARREADY = 0;
        AXI_LITE_RDATA   = 0;
        AXI_LITE_RRESP   = 0;
        AXI_LITE_RVALID  = 0;
    endtask

    initial begin
        forever begin
            bus_reset;
            if( RST ) @(negedge RST);
            fork
                get_req_aw  ;
                get_req_w   ;
                write_mem   ;
                get_req_ar  ;
                read_mem    ;
            join_none
            @(posedge RST);
            disable fork;
        end
    end

endmodule