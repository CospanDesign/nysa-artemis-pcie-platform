/*
Distributed under the MIT license.
Copyright (c) 2015 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
 * Author:
 * Description:
 *
 * Changes:
 */

module artemis_pcie_interface #(
  parameter CONTROL_FIFO_DEPTH        = 7,
  parameter DATA_FIFO_DEPTH           = 9,
  parameter SERIAL_NUMBER             = 64'h000000000000C594
)(
  input                     clk,
  input                     rst,

  //The Following Signals are clocked at 62.5MHz

  // PCI Express Fabric Interface
  input                     gtp_clk_p,
  input                     gtp_clk_n,

  output                    pci_exp_txp,
  output                    pci_exp_txn,
  input                     pci_exp_rxp,
  input                     pci_exp_rxn,

  // Transaction (TRN) Interface
  output                    user_lnk_up,


  // Flow Control
  input       [2:0]         fc_sel,
  output      [7:0]         fc_nph,
  output      [11:0]        fc_npd,
  output      [7:0]         fc_ph,
  output      [11:0]        fc_pd,
  output      [7:0]         fc_cplh,
  output      [11:0]        fc_cpld,

  // Host (CFG) Interface
  output      [31:0]        cfg_do,
  output                    cfg_rd_wr_done,
  input       [9:0]         cfg_dwaddr,
  input                     cfg_rd_en,

  // Configuration: Error
  input                     cfg_err_ur,
  input                     cfg_err_cor,
  input                     cfg_err_ecrc,
  input                     cfg_err_cpl_timeout,
  input                     cfg_err_cpl_abort,
  input                     cfg_err_posted,
  input                     cfg_err_locked,
  input       [47:0]        cfg_err_tlp_cpl_header,
  output                    cfg_err_cpl_rdy,

  // Conifguration: Interrupt
  input                     cfg_interrupt,
  output                    cfg_interrupt_rdy,
  input                     cfg_interrupt_assert,
  output      [7:0]         cfg_interrupt_do,
  input       [7:0]         cfg_interrupt_di,
  output      [2:0]         cfg_interrupt_mmenable,
  output                    cfg_interrupt_msienable,

  // Configuration: Power Management
  input                     cfg_turnoff_ok,
  output                    cfg_to_turnoff,
  input                     cfg_pm_wake,

  // Configuration: System/Status
  output      [2:0]         cfg_pcie_link_state,
  input                     cfg_trn_pending_stb,
  output      [7:0]         cfg_bus_number,
  output      [4:0]         cfg_device_number,
  output      [2:0]         cfg_function_number,

  output      [15:0]        cfg_status,
  output      [15:0]        cfg_command,
  output      [15:0]        cfg_dstatus,
  output      [15:0]        cfg_dcommand,
  output      [15:0]        cfg_lstatus,
  output      [15:0]        cfg_lcommand,

  // System Interface
  output                    pcie_reset,
  output                    received_hot_reset,

  input                     i_cmd_in_rd_stb,
  output                    o_cmd_in_rd_ready,
  input                     i_cmd_in_rd_activate,
  output      [23:0]        o_cmd_in_rd_count,
  output      [31:0]        o_cmd_in_rd_data,

  output      [1:0]         o_cmd_out_wr_ready,
  input       [1:0]         i_cmd_out_wr_activate,
  output      [23:0]        o_cmd_out_wr_size,
  input                     i_cmd_out_wr_stb,
  input       [31:0]        i_cmd_out_wr_data,

  input                     i_data_in_rd_stb,
  output                    o_data_in_rd_ready,
  input                     i_data_in_rd_activate,
  output      [23:0]        o_data_in_rd_count,
  output      [31:0]        o_data_in_rd_data,

  output      [1:0]         o_data_out_wr_ready,
  input       [1:0]         i_data_out_wr_activate,
  output      [23:0]        o_data_out_wr_size,
  input                     i_data_out_wr_stb,
  input       [31:0]        i_data_out_wr_data

);

//local parameters
localparam      CONTROL_FIFO_SIZE     = (2 ** CONTROL_FIFO_DEPTH);
localparam      DATA_FIFO_SIZE        = (2 ** DATA_FIFO_DEPTH);


localparam      CONTROL_FUNCTION_ID   = 1'b0;
localparam      DATA_FUNCTION_ID      = 1'b1;
//registes/wires


wire                        clk_62p5;


//Control Signals
wire  [1:0]                 c_in_wr_ready;
wire  [1:0]                 c_in_wr_activate;
wire  [23:0]                c_in_wr_size;
wire                        c_in_wr_stb;
wire  [31:0]                c_in_wr_data;


wire                        c_out_rd_stb;
wire                        c_out_rd_ready;
wire                        c_out_rd_activate;
wire  [23:0]                c_out_rd_size;
wire  [31:0]                c_out_rd_data;



//Data
wire  [1:0]                 d_in_wr_ready;
wire  [1:0]                 d_in_wr_activate;
wire  [23:0]                d_in_wr_size;
wire                        d_in_wr_stb;
wire  [31:0]                d_in_wr_data;

wire                        d_out_rd_stb;
wire                        d_out_rd_ready;
wire                        d_out_rd_activate;
wire  [23:0]                d_out_rd_size;
wire  [31:0]                d_out_rd_data;


wire                        axi_clk;
wire                        axi_ppfifo_clk;

//Control Signals
wire                        c_in_axi_ready;
wire          [31:0]        c_in_axi_data;
wire          [3:0]         c_in_axi_keep;
wire                        c_in_axi_last;
wire                        c_in_axi_valid;

wire                        c_out_axi_ready;
wire          [31:0]        c_out_axi_data;
wire          [3:0]         c_out_axi_keep;
wire                        c_out_axi_last;
wire                        c_out_axi_valid;


//Data Signals
wire                        d_in_axi_ready;
wire          [31:0]        d_in_axi_data;
wire          [3:0]         d_in_axi_keep;
wire                        d_in_axi_last;
wire                        d_in_axi_valid;

wire                        d_out_axi_ready;
wire          [31:0]        d_out_axi_data;
wire          [3:0]         d_out_axi_keep;
wire                        d_out_axi_last;
wire                        d_out_axi_valid;

wire          [31:0]        m_axis_rx_tdata;
wire          [3:0]         m_axis_rx_tkeep;
wire                        m_axis_rx_tlast;
wire                        m_axis_rx_tvalid;
wire                        m_axis_rx_tready;

wire                        s_axis_tx_tready;
wire          [31:0]        s_axis_tx_tdata;
wire          [3:0]         s_axis_tx_tkeep;
wire          [3:0]         s_axis_tx_tuser;
wire                        s_axis_tx_tlast;
wire                        s_axis_tx_tvalid;

wire                        cfg_trn_pending;



//submodules
cross_clock_strobe trn_pnd(
  .in_clk           (clk                ),
  .in_stb           (cfg_trn_pending_stb),

  .out_clk          (clk_62p5           ),
  .out_stb          (cfg_trn_pending    )
);


`ifdef SIMULATION

sim_pcie_axi_bridge #(
  .USR_CLK_DIVIDE                     (4                      )
)pcie_interface(
`else
pcie_axi_bridge pcie_interface(

`endif

  // PCI Express Fabric Interface
  .pci_exp_txp                       (pci_exp_txp             ),
  .pci_exp_txn                       (pci_exp_txn             ),
  .pci_exp_rxp                       (pci_exp_rxp             ),
  .pci_exp_rxn                       (pci_exp_rxn             ),

  // Transaction (TRN) Interface
  .user_lnk_up                       (user_lnk_up             ),

  // Tx
  .s_axis_tx_tready                  (s_axis_tx_tready        ),
  .s_axis_tx_tdata                   (s_axis_tx_tdata         ),
  .s_axis_tx_tkeep                   (s_axis_tx_tkeep         ),
  .s_axis_tx_tuser                   (s_axis_tx_tuser         ),
  .s_axis_tx_tlast                   (s_axis_tx_tlast         ),
  .s_axis_tx_tvalid                  (s_axis_tx_tvalid        ),

/*
//TODO
  output  reg [5:0]   tx_buf_av,
  output  reg         tx_err_drop,
  input               tx_cfg_gnt,
  output  reg         tx_cfg_req,
*/

  // Rx
  .m_axis_rx_tdata                   (m_axis_rx_tdata         ),
  .m_axis_rx_tkeep                   (m_axis_rx_tkeep         ),
  .m_axis_rx_tlast                   (m_axis_rx_tlast         ),
  .m_axis_rx_tvalid                  (m_axis_rx_tvalid        ),
  .m_axis_rx_tready                  (m_axis_rx_tready        ),
//  output  reg [21:0]  m_axis_rx_tuser,
//  input               rx_np_ok,

  // Flow Control
  .fc_sel                            (fc_sel                  ),
  .fc_nph                            (fc_nph                  ),
  .fc_npd                            (fc_npd                  ),
  .fc_ph                             (fc_ph                   ),
  .fc_pd                             (fc_pd                   ),
  .fc_cplh                           (fc_cplh                 ),
  .fc_cpld                           (fc_cpld                 ),

  // Host Interface
  .cfg_do                            (cfg_do                  ),
  .cfg_rd_wr_done                    (cfg_rd_wr_done          ),
  .cfg_dwaddr                        (cfg_dwaddr              ),
  .cfg_rd_en                         (cfg_rd_en               ),

  // Configuration: Error
  .cfg_err_ur                        (cfg_err_ur              ),
  .cfg_err_cor                       (cfg_err_cor             ),
  .cfg_err_ecrc                      (cfg_err_ecrc            ),
  .cfg_err_cpl_timeout               (cfg_err_cpl_timeout     ),
  .cfg_err_cpl_abort                 (cfg_err_cpl_abort       ),
  .cfg_err_posted                    (cfg_err_posted          ),
  .cfg_err_locked                    (cfg_err_locked          ),
  .cfg_err_tlp_cpl_header            (cfg_err_tlp_cpl_header  ),
  .cfg_err_cpl_rdy                   (cfg_err_cpl_rdy         ),

  // Conifguration: Interrupt
  .cfg_interrupt                     (cfg_interrupt           ),
  .cfg_interrupt_rdy                 (cfg_interrupt_rdy       ),
  .cfg_interrupt_assert              (cfg_interrupt_assert    ),
  .cfg_interrupt_do                  (cfg_interrupt_do        ),
  .cfg_interrupt_di                  (cfg_interrupt_di        ),
  .cfg_interrupt_mmenable            (cfg_interrupt_mmenable  ),
  .cfg_interrupt_msienable           (cfg_interrupt_msienable ),

  // Configuration: Power Management
  .cfg_turnoff_ok                    (cfg_turnoff_ok          ),
  .cfg_to_turnoff                    (cfg_to_turnoff          ),
  .cfg_pm_wake                       (cfg_pm_wake             ),

  // Configuration: System/Status
  .cfg_pcie_link_state               (cfg_pcie_link_state     ),
  .cfg_trn_pending                   (cfg_trn_pending         ),
  .cfg_dsn                           (SERIAL_NUMBER           ),
  .cfg_bus_number                    (cfg_bus_number          ),
  .cfg_device_number                 (cfg_device_number       ),
  .cfg_function_number               (cfg_function_number     ),

  .cfg_status                        (cfg_status              ),
  .cfg_command                       (cfg_command             ),
  .cfg_dstatus                       (cfg_dstatus             ),
  .cfg_dcommand                      (cfg_dcommand            ),
  .cfg_lstatus                       (cfg_lstatus             ),
  .cfg_lcommand                      (cfg_lcommand            ),

  // System Interface
  .sys_clk_p                         (gtp_clk_p               ),
  .sys_clk_n                         (gtp_clk_n               ),
  .sys_reset                         (rst                     ),
  .user_clk_out                      (clk_62p5                ),
  .user_reset_out                    (pcie_reset              ),
  .received_hot_reset                (received_hot_reset      )
);

adapter_axi_stream_2_ppfifo cntrl_a2p (
  .rst              (pcie_reset       ),

  //AXI Stream Input
  .i_axi_clk        (axi_clk          ),
  .o_axi_ready      (c_in_axi_ready   ),
  .i_axi_data       (c_in_axi_data    ),
  .i_axi_keep       (c_in_axi_keep    ),
  .i_axi_last       (c_in_axi_last    ),
  .i_axi_valid      (c_in_axi_valid   ),

  //Ping Pong FIFO Write Controller
  .o_ppfifo_clk     (axi_ppfifo_clk   ),
  .i_ppfifo_rdy     (c_in_wr_ready    ),
  .o_ppfifo_act     (c_in_wr_activate ),
  .i_ppfifo_size    (c_in_wr_size     ),
  .o_ppfifo_stb     (c_in_wr_stb      ),
  .o_ppfifo_data    (c_in_wr_data     )

);

ppfifo #(
  .DATA_WIDTH       (32               ),
  .ADDRESS_WIDTH    (CONTROL_FIFO_DEPTH - 2)
) pcie_control_ingress (

  //Control Signals
  .reset            (pcie_reset       ),

  //Write Side
  .write_clock      (axi_ppfifo_clk   ),
  .write_ready      (c_in_wr_ready    ),
  .write_activate   (c_in_wr_activate ),
  .write_fifo_size  (c_in_wr_size     ),
  .write_strobe     (c_in_wr_stb      ),
  .write_data       (c_in_wr_data     ),
  .starved          (                 ),

  //Read Size
  .read_clock       (clk                  ),
  .read_strobe      (i_cmd_in_rd_stb      ),
  .read_ready       (o_cmd_in_rd_ready    ),
  .read_activate    (i_cmd_in_rd_activate ),
  .read_count       (o_cmd_in_rd_count    ),
  .read_data        (o_cmd_in_rd_data     ),
  .inactive         (                     )
);

ppfifo #(
  .DATA_WIDTH       (32               ),
  .ADDRESS_WIDTH    (CONTROL_FIFO_DEPTH - 2)
) pcie_control_egress (

  //Control Signals
  .reset            (pcie_reset       ),

  //Write Side
  .write_clock      (clk              ),
  .write_ready      (o_cmd_out_wr_ready   ),
  .write_activate   (i_cmd_out_wr_activate),
  .write_fifo_size  (o_cmd_out_wr_size    ),
  .write_strobe     (i_cmd_out_wr_stb     ),
  .write_data       (i_cmd_out_wr_data    ),
  .starved          (                 ),

  //Read Size
  .read_clock       (axi_ppfifo_clk   ),
  .read_strobe      (c_out_rd_stb     ),
  .read_ready       (c_out_rd_ready   ),
  .read_activate    (c_out_rd_activate),
  .read_count       (c_out_rd_size    ),
  .read_data        (c_out_rd_data    ),
  .inactive         (                 )
);


adapter_ppfifo_2_axi_stream control_p2a (
  .rst              (pcie_reset       ),

  //Ping Poing FIFO Read Interface
  .i_ppfifo_clk     (axi_ppfifo_clk   ),
  .i_ppfifo_rdy     (c_out_rd_ready   ),
  .o_ppfifo_act     (c_out_rd_activate),
  .i_ppfifo_size    (c_out_rd_size    ),
  .i_ppfifo_data    (c_out_rd_data    ),
  .o_ppfifo_stb     (c_out_rd_stb     ),

  //AXI Stream Output
  .o_axi_clk        (                 ),
  .i_axi_ready      (c_out_axi_ready  ),
  .o_axi_data       (c_out_axi_data   ),
  .o_axi_keep       (c_out_axi_keep   ),
  .o_axi_last       (c_out_axi_last   ),
  .o_axi_valid      (c_out_axi_valid  )

);

//Data FIFOs
adapter_axi_stream_2_ppfifo data_a2p (
  .rst              (pcie_reset       ),

  //AXI Stream Input
  .i_axi_clk        (axi_clk          ),
  .o_axi_ready      (d_in_axi_ready   ),
  .i_axi_data       (d_in_axi_data    ),
  .i_axi_keep       (d_in_axi_keep    ),
  .i_axi_last       (d_in_axi_last    ),
  .i_axi_valid      (d_in_axi_valid   ),

  //Ping Pong FIFO Write Controller
  .o_ppfifo_clk     (                 ),
  .i_ppfifo_rdy     (d_in_wr_ready    ),
  .o_ppfifo_act     (d_in_wr_activate ),
  .i_ppfifo_size    (d_in_wr_size     ),
  .o_ppfifo_stb     (d_in_wr_stb      ),
  .o_ppfifo_data    (d_in_wr_data     )
);

ppfifo #(
  .DATA_WIDTH       (32               ),
  .ADDRESS_WIDTH    (DATA_FIFO_DEPTH - 2 )
) pcie_data_ingress (

  //Control Signals
  .reset            (pcie_reset       ),

  //Write Side
  .write_clock      (axi_ppfifo_clk   ),
  .write_ready      (d_in_wr_ready    ),
  .write_activate   (d_in_wr_activate ),
  .write_fifo_size  (d_in_wr_size     ),
  .write_strobe     (d_in_wr_stb      ),
  .write_data       (d_in_wr_data     ),
  .starved          (),

  //Read Size
  .read_clock       (clk              ),
  .read_strobe      (i_data_in_rd_stb      ),
  .read_ready       (o_data_in_rd_ready    ),
  .read_activate    (i_data_in_rd_activate ),
  .read_count       (o_data_in_rd_count    ),
  .read_data        (o_data_in_rd_data     ),
  .inactive         ()
);


ppfifo #(
  .DATA_WIDTH       (32               ),
  .ADDRESS_WIDTH    (DATA_FIFO_DEPTH - 2 )
) pcie_data_egress (

  //Control Signals
  .reset            (pcie_reset       ),

  //Write Side
  .write_clock      (clk              ),
  .write_ready      (o_data_out_wr_ready   ),
  .write_activate   (i_data_out_wr_activate),
  .write_fifo_size  (o_data_out_wr_size    ),
  .write_strobe     (i_data_out_wr_stb     ),
  .write_data       (i_data_out_wr_data    ),
  .starved          (),

  //Read Size
  .read_clock       (axi_ppfifo_clk   ),
  .read_strobe      (d_out_rd_stb     ),
  .read_ready       (d_out_rd_ready   ),
  .read_activate    (d_out_rd_activate),
  .read_count       (d_out_rd_size    ),
  .read_data        (d_out_rd_data    ),
  .inactive         ()
);

adapter_ppfifo_2_axi_stream data_p2a (
  .rst              (pcie_reset       ),

  //Ping Poing FIFO Read Interface
  .i_ppfifo_clk     (axi_ppfifo_clk   ),
  .i_ppfifo_rdy     (d_out_rd_ready   ),
  .o_ppfifo_act     (d_out_rd_activate),
  .i_ppfifo_size    (d_out_rd_size    ),
  .i_ppfifo_data    (d_out_rd_data    ),
  .o_ppfifo_stb     (d_out_rd_stb     ),

  //AXI Stream Output
  .o_axi_clk        (                 ),
  .i_axi_ready      (d_out_axi_ready  ),
  .o_axi_data       (d_out_axi_data   ),
  .o_axi_keep       (d_out_axi_keep   ),
  .o_axi_last       (d_out_axi_last   ),
  .o_axi_valid      (d_out_axi_valid  )
);

//asynchronous logic

assign  axi_clk             = clk_62p5;

//Map the PCIE to PPFIFO FIFO

assign  m_axis_rx_tready  = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? c_in_axi_ready : d_in_axi_ready;

assign  c_in_axi_data     = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? m_axis_rx_tdata: 32'h00000000;
assign  d_in_axi_data     = (cfg_function_number[0] == DATA_FUNCTION_ID)    ? m_axis_rx_tdata: 32'h00000000;

assign  c_in_axi_keep     = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? m_axis_rx_tkeep: 32'h00000000;
assign  d_in_axi_keep     = (cfg_function_number[0] == DATA_FUNCTION_ID)    ? m_axis_rx_tkeep: 32'h00000000;

assign  c_in_axi_last     = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? m_axis_rx_tlast: 32'h00000000;
assign  d_in_axi_last     = (cfg_function_number[0] == DATA_FUNCTION_ID)    ? m_axis_rx_tlast: 32'h00000000;

assign  c_in_axi_valid    = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? m_axis_rx_tvalid: 32'h00000000;
assign  d_in_axi_valid    = (cfg_function_number[0] == DATA_FUNCTION_ID)    ? m_axis_rx_tvalid: 32'h00000000;


assign  c_out_axi_data     = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? s_axis_tx_tready: 32'h00000000;
assign  d_out_axi_data     = (cfg_function_number[0] == DATA_FUNCTION_ID)    ? s_axis_tx_tready: 32'h00000000;


assign  s_axis_tx_tdata   = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? c_out_axi_data  : d_out_axi_data;
assign  s_axis_tx_tkeep   = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? c_out_axi_keep  : d_out_axi_keep;
assign  s_axis_tx_tlast   = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? c_out_axi_last  : d_out_axi_last;
assign  s_axis_tx_tvalid  = (cfg_function_number[0] == CONTROL_FUNCTION_ID) ? c_out_axi_valid : d_out_axi_valid;

//synchronous logic
endmodule