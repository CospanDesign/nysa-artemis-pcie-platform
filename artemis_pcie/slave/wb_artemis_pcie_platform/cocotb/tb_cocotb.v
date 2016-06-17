`timescale 1ns/1ps

module tb_cocotb (

//Virtual Host Interface Signals
input             clk,

input             rst,
output            master_ready,
input             in_ready,
input   [31:0]    in_command,
input   [31:0]    in_address,
input   [31:0]    in_data,
input   [27:0]    in_data_count,

input             out_ready,
output            out_en,
output  [31:0]    out_status,
output  [31:0]    out_address,
output  [31:0]    out_data,
output  [27:0]    out_data_count,
input   [31:0]    test_id,

input             ih_reset,
output            device_interrupt

);

localparam           CONTROL_FIFO_DEPTH = 7;

//Parameters
//Registers/Wires

reg               r_rst;
reg               r_in_ready;
reg   [31:0]      r_in_command;
reg   [31:0]      r_in_address;
reg   [31:0]      r_in_data;
reg   [27:0]      r_in_data_count;
reg               r_out_ready;
reg               r_ih_reset;

reg               w_clk_100mhz_clk_p;
reg               w_clk_100mhz_clk_n;

reg               r_pcie_reset_n    = 0;


//There is a bug in COCOTB when stiumlating a signal, sometimes it can be corrupted if not registered
always @ (*) r_rst           = rst;
always @ (*) r_in_ready      = in_ready;
always @ (*) r_in_command    = in_command;
always @ (*) r_in_address    = in_address;
always @ (*) r_in_data       = in_data;
always @ (*) r_in_data_count = in_data_count;
always @ (*) r_out_ready     = out_ready;
always @ (*) r_ih_reset      = ih_reset;

always @ (*) w_clk_100mhz_clk_p      = clk;
always @ (*) w_clk_100mhz_clk_n      = !clk;

//wishbone signals
wire              w_wbp_we;
wire              w_wbp_cyc;
wire              w_wbp_stb;
wire [3:0]        w_wbp_sel;
wire [31:0]       w_wbp_adr;
wire [31:0]       w_wbp_dat_o;
wire [31:0]       w_wbp_dat_i;
wire              w_wbp_ack;
wire              w_wbp_int;

//Wishbone Slave 0 (SDB) signals
wire              w_wbs0_we;
wire              w_wbs0_cyc;
wire  [31:0]      w_wbs0_dat_o;
wire              w_wbs0_stb;
wire  [3:0]       w_wbs0_sel;
wire              w_wbs0_ack;
wire  [31:0]      w_wbs0_dat_i;
wire  [31:0]      w_wbs0_adr;
wire              w_wbs0_int;

//mem slave 0
wire              w_sm0_i_wbs_we;
wire              w_sm0_i_wbs_cyc;
wire  [31:0]      w_sm0_i_wbs_dat;
wire  [31:0]      w_sm0_o_wbs_dat;
wire  [31:0]      w_sm0_i_wbs_adr;
wire              w_sm0_i_wbs_stb;
wire  [3:0]       w_sm0_i_wbs_sel;
wire              w_sm0_o_wbs_ack;
wire              w_sm0_o_wbs_int;

//wishbone slave 1 (Unit Under Test) signals
wire              w_wbs1_we;
wire              w_wbs1_cyc;
wire              w_wbs1_stb;
wire  [3:0]       w_wbs1_sel;
wire              w_wbs1_ack;
wire  [31:0]      w_wbs1_dat_i;
wire  [31:0]      w_wbs1_dat_o;
wire  [31:0]      w_wbs1_adr;
wire              w_wbs1_int;

//Memory Interface
wire              w_mem_we_o;
wire              w_mem_cyc_o;
wire              w_mem_stb_o;
wire  [3:0]       w_mem_sel_o;
wire  [31:0]      w_mem_adr_o;
wire  [31:0]      w_mem_dat_i;
wire  [31:0]      w_mem_dat_o;
wire              w_mem_ack_i;
wire              w_mem_int_i;

wire              w_arb0_i_wbs_stb;
wire              w_arb0_i_wbs_cyc;
wire              w_arb0_i_wbs_we;
wire  [3:0]       w_arb0_i_wbs_sel;
wire  [31:0]      w_arb0_i_wbs_dat;
wire  [31:0]      w_arb0_o_wbs_dat;
wire  [31:0]      w_arb0_i_wbs_adr;
wire              w_arb0_o_wbs_ack;
wire              w_arb0_o_wbs_int;


wire              mem_o_we;
wire              mem_o_stb;
wire              mem_o_cyc;
wire  [3:0]       mem_o_sel;
wire  [31:0]      mem_o_adr;
wire  [31:0]      mem_o_dat;
wire  [31:0]      mem_i_dat;
wire              mem_i_ack;
wire              mem_i_int;

//Artemis PCIE Interface
wire               w_pcie_reset;
wire               w_pcie_per_fifo_sel;
wire               w_pcie_mem_fifo_sel;
wire               w_pcie_dma_fifo_sel;

wire               w_pcie_write_fin;
wire               w_pcie_read_fin;

wire   [31:0]      w_pcie_data_size;
wire   [31:0]      w_pcie_data_address;
wire               w_pcie_data_fifo_flg;
wire               w_pcie_data_read_flg;
wire               w_pcie_data_write_flg;

wire               w_pcie_interrupt_stb;
wire   [31:0]      w_pcie_interrupt_value;

wire               w_pcie_data_clk;
wire               w_pcie_ingress_fifo_rdy;
wire               w_pcie_ingress_fifo_act;
wire   [23:0]      w_pcie_ingress_fifo_size;
wire               w_pcie_ingress_fifo_stb;
wire   [31:0]      w_pcie_ingress_fifo_data;
wire               w_pcie_ingress_fifo_idle;

wire   [1:0]       w_pcie_egress_fifo_rdy;
wire   [1:0]       w_pcie_egress_fifo_act;
wire   [23:0]      w_pcie_egress_fifo_size;
wire               w_pcie_egress_fifo_stb;
wire   [31:0]      w_pcie_egress_fifo_data;

//Master Interface
wire               w_master_ready;

wire               w_ih_reset;
wire               w_ih_ready;

wire   [31:0]      w_in_command;
wire   [31:0]      w_in_address;
wire   [31:0]      w_in_data;
wire   [27:0]      w_in_data_count;

wire               w_out_ready;
wire               w_out_en;

wire   [31:0]      w_out_status;
wire   [31:0]      w_out_address;
wire   [31:0]      w_out_data;
wire   [27:0]      w_out_data_count;

wire   [31:0]      w_usr_interrupt_value;

//Memorce
wire               w_ddr3_cmd_clk;
wire               w_ddr3_cmd_en;
wire   [2:0]       w_ddr3_cmd_instr;
wire   [5:0]       w_ddr3_cmd_bl;
wire   [29:0]      w_ddr3_cmd_byte_addr;
wire               w_ddr3_cmd_empty;
wire               w_ddr3_cmd_full;

wire               w_ddr3_wr_clk;
wire               w_ddr3_wr_en;
wire   [3:0]       w_ddr3_wr_mask;
wire   [31:0]      w_ddr3_wr_data;
wire               w_ddr3_wr_full;
wire               w_ddr3_wr_empty;
wire   [6:0]       w_ddr3_wr_count;
wire               w_ddr3_wr_underrun;
wire               w_ddr3_wr_error;

wire               w_ddr3_rd_clk;
wire               w_ddr3_rd_en;
wire   [31:0]      w_ddr3_rd_data;
wire               w_ddr3_rd_full;
wire               w_ddr3_rd_empty;
wire   [6:0]       w_ddr3_rd_count;
wire               w_ddr3_rd_overflow;
wire               w_ddr3_rd_error;

//DMA I
wire               w_idma_activate;
wire               w_idma_ready;
wire               w_idma_stb;
wire   [23:0]      w_idma_size;
wire   [31:0]      w_idma_data;

wire   [1:0]       w_odma_ready;
wire   [1:0]       w_odma_activate;
wire               w_odma_stb;
wire   [23:0]      w_odma_size;
wire   [31:0]      w_odma_data;


wire   [31:0]      w_debug;
reg                r_cancel_write_stb;
wire   [31:0]      w_num_reads;
wire               w_read_idle;

reg     [31:0]     r_per_data;
wire               w_per_stb;
wire               w_per_cyc;
reg                r_per_ack;

reg                r_bram_we;
wire    [6:0]      w_bram_addr;
reg     [31:0]     r_bram_din;
wire    [31:0]     w_bram_dout;
wire               w_bram_valid;

wire    [1:0]      w_mem_gen_rdy;
wire    [23:0]     w_mem_gen_size;
wire    [1:0]      w_mem_gen_act;
wire               w_mem_gen_stb;
wire    [31:0]     w_mem_gen_data;
        
wire               w_mem_sink_rdy;
wire    [23:0]     w_mem_sink_size;
wire               w_mem_sink_act;
wire               w_mem_sink_stb;
wire    [31:0]     w_mem_sink_data;
        
wire               w_odma_flush;
wire               w_idma_flush;
        
wire    [1:0]      w_dma_gen_rdy;
wire    [23:0]     w_dma_gen_size;
wire    [1:0]      w_dma_gen_act;
wire               w_dma_gen_stb;
wire    [31:0]     w_dma_gen_data;
        
wire               w_dma_sink_rdy;
wire    [23:0]     w_dma_sink_size;
wire               w_dma_sink_act;
wire               w_dma_sink_stb;
wire    [31:0]     w_dma_sink_data;






//Submodules
wishbone_master wm (
  .clk            (clk            ),
  .rst            (r_rst          ),

  .i_ih_rst       (r_ih_reset     ),
  .i_ready        (r_in_ready     ),
  .i_command      (r_in_command   ),
  .i_address      (r_in_address   ),
  .i_data         (r_in_data      ),
  .i_data_count   (r_in_data_count),
  .i_out_ready    (r_out_ready    ),
  .o_en           (out_en         ),
  .o_status       (out_status     ),
  .o_address      (out_address    ),
  .o_data         (out_data       ),
  .o_data_count   (out_data_count ),
  .o_master_ready (master_ready   ),

  .o_per_we       (w_wbp_we         ),
  .o_per_adr      (w_wbp_adr        ),
  .o_per_dat      (w_wbp_dat_i      ),
  .i_per_dat      (w_wbp_dat_o      ),
  .o_per_stb      (w_wbp_stb        ),
  .o_per_cyc      (w_wbp_cyc        ),
  .o_per_msk      (w_wbp_msk        ),
  .o_per_sel      (w_wbp_sel        ),
  .i_per_ack      (w_wbp_ack        ),
  .i_per_int      (w_wbp_int        ),

  //memory interconnect signals
  .o_mem_we       (w_mem_we_o       ),
  .o_mem_adr      (w_mem_adr_o      ),
  .o_mem_dat      (w_mem_dat_o      ),
  .i_mem_dat      (w_mem_dat_i      ),
  .o_mem_stb      (w_mem_stb_o      ),
  .o_mem_cyc      (w_mem_cyc_o      ),
  .o_mem_sel      (w_mem_sel_o      ),
  .i_mem_ack      (w_mem_ack_i      ),
  .i_mem_int      (w_mem_int_i      )

);

//slave 1
wb_artemis_pcie_platform #(
  .CONTROL_FIFO_DEPTH        (CONTROL_FIFO_DEPTH       )
) s1 (

  .clk                      (clk                      ),
  .rst                      (r_rst                    ),

  //Artemis PCIE Interface
  .o_pcie_reset             (w_pcie_reset             ),
  .o_pcie_per_fifo_sel      (w_pcie_per_fifo_sel      ),
  .o_pcie_mem_fifo_sel      (w_pcie_mem_fifo_sel      ),
  .o_pcie_dma_fifo_sel      (w_pcie_dma_fifo_sel      ),

  .i_pcie_write_fin         (w_pcie_write_fin         ),
  .i_pcie_read_fin          (w_pcie_read_fin          ),

  .o_pcie_data_size         (w_pcie_data_size         ),
  .o_pcie_data_address      (w_pcie_data_address      ),
  .o_pcie_data_fifo_flg     (w_pcie_data_fifo_flg     ),
  .o_pcie_data_read_flg     (w_pcie_data_read_flg     ),
  .o_pcie_data_write_flg    (w_pcie_data_write_flg    ),

  .i_pcie_interrupt_stb     (w_pcie_interrupt_stb     ),
  .i_pcie_interrupt_value   (w_pcie_interrupt_value   ),

  .i_pcie_data_clk          (w_pcie_data_clk          ),
  .o_pcie_ingress_fifo_rdy  (w_pcie_ingress_fifo_rdy  ),
  .i_pcie_ingress_fifo_act  (w_pcie_ingress_fifo_act  ),
  .o_pcie_ingress_fifo_size (w_pcie_ingress_fifo_size ),
  .i_pcie_ingress_fifo_stb  (w_pcie_ingress_fifo_stb  ),
  .o_pcie_ingress_fifo_data (w_pcie_ingress_fifo_data ),
  .o_pcie_ingress_fifo_idle (w_pcie_ingress_fifo_idle ),

  .o_pcie_egress_fifo_rdy   (w_pcie_egress_fifo_rdy   ),
  .i_pcie_egress_fifo_act   (w_pcie_egress_fifo_act   ),
  .o_pcie_egress_fifo_size  (w_pcie_egress_fifo_size  ),
  .i_pcie_egress_fifo_stb   (w_pcie_egress_fifo_stb   ),
  .i_pcie_egress_fifo_data  (w_pcie_egress_fifo_data  ),

  //PCIE Phy Interface
  .i_clk_100mhz_gtp_p       (w_clk_100mhz_clk_p       ),
  .i_clk_100mhz_gtp_n       (w_clk_100mhz_clk_n       ),

  .i_pcie_reset_n           (r_pcie_reset_n           ),

  .i_wbs_we                 (w_wbs1_we                ),
  .i_wbs_sel                (4'b1111                  ),
  .i_wbs_cyc                (w_wbs1_cyc               ),
  .i_wbs_dat                (w_wbs1_dat_i             ),
  .i_wbs_stb                (w_wbs1_stb               ),
  .o_wbs_ack                (w_wbs1_ack               ),
  .o_wbs_dat                (w_wbs1_dat_o             ),
  .i_wbs_adr                (w_wbs1_adr               ),
  .o_wbs_int                (w_wbs1_int               )
);

artemis_pcie_host_interface host_interface (
  .clk                      (clk                      ),
  .rst                      (r_rst                    ),

  //Artemis PCIE Interface
  .i_pcie_reset             (w_pcie_reset             ),
  .i_pcie_per_fifo_sel      (w_pcie_per_fifo_sel      ),
  .i_pcie_mem_fifo_sel      (w_pcie_mem_fifo_sel      ),
  .i_pcie_dma_fifo_sel      (w_pcie_dma_fifo_sel      ),

  .o_pcie_write_fin         (w_pcie_write_fin         ),
  .o_pcie_read_fin          (w_pcie_read_fin          ),

  .i_pcie_data_size         (w_pcie_data_size         ),
  .i_pcie_data_address      (w_pcie_data_address      ),
  .i_pcie_data_fifo_flg     (w_pcie_data_fifo_flg     ),
  .i_pcie_data_read_flg     (w_pcie_data_read_flg     ),
  .i_pcie_data_write_flg    (w_pcie_data_write_flg    ),

  .o_pcie_interrupt_stb     (w_pcie_interrupt_stb     ),
  .o_pcie_interrupt_value   (w_pcie_interrupt_value   ),

  .o_pcie_data_clk          (w_pcie_data_clk          ),
  .i_pcie_ingress_fifo_rdy  (w_pcie_ingress_fifo_rdy  ),
  .o_pcie_ingress_fifo_act  (w_pcie_ingress_fifo_act  ),
  .i_pcie_ingress_fifo_size (w_pcie_ingress_fifo_size ),
  .o_pcie_ingress_fifo_stb  (w_pcie_ingress_fifo_stb  ),
  .i_pcie_ingress_fifo_data (w_pcie_ingress_fifo_data ),
  .i_pcie_ingress_fifo_idle (w_pcie_ingress_fifo_idle ),

  .i_pcie_egress_fifo_rdy   (w_pcie_egress_fifo_rdy   ),
  .o_pcie_egress_fifo_act   (w_pcie_egress_fifo_act   ),
  .i_pcie_egress_fifo_size  (w_pcie_egress_fifo_size  ),
  .o_pcie_egress_fifo_stb   (w_pcie_egress_fifo_stb   ),
  .o_pcie_egress_fifo_data  (w_pcie_egress_fifo_data  ),

  //Master Interface
  .i_master_ready           (w_master_ready           ),

  .o_ih_reset               (w_ih_reset               ),
  .o_ih_ready               (w_ih_ready               ),

  .o_in_command             (w_in_command             ),
  .o_in_address             (w_in_address             ),
  .o_in_data                (w_in_data                ),
  .o_in_data_count          (w_in_data_count          ),

  .o_oh_ready               (w_out_ready              ),
  .i_oh_en                  (w_out_en                 ),

  .i_out_status             (w_out_status             ),
  .i_out_address            (w_out_address            ),
  .i_out_data               (w_out_data               ),
  .i_out_data_count         (w_out_data_count         ),

  .i_usr_interrupt_value    (w_usr_interrupt_value    ),

  //Memory Interface
  .o_ddr3_cmd_clk           (w_ddr3_cmd_clk           ),
  .o_ddr3_cmd_en            (w_ddr3_cmd_en            ),
  .o_ddr3_cmd_instr         (w_ddr3_cmd_instr         ),
  .o_ddr3_cmd_bl            (w_ddr3_cmd_bl            ),
  .o_ddr3_cmd_byte_addr     (w_ddr3_cmd_byte_addr     ),
  .i_ddr3_cmd_empty         (w_ddr3_cmd_empty         ),
  .i_ddr3_cmd_full          (w_ddr3_cmd_full          ),

  .o_ddr3_wr_clk            (w_ddr3_wr_clk            ),
  .o_ddr3_wr_en             (w_ddr3_wr_en             ),
  .o_ddr3_wr_mask           (w_ddr3_wr_mask           ),
  .o_ddr3_wr_data           (w_ddr3_wr_data           ),
  .i_ddr3_wr_full           (w_ddr3_wr_full           ),
  .i_ddr3_wr_empty          (w_ddr3_wr_empty          ),
  .i_ddr3_wr_count          (w_ddr3_wr_count          ),
  .i_ddr3_wr_underrun       (w_ddr3_wr_underrun       ),
  .i_ddr3_wr_error          (w_ddr3_wr_error          ),

  .o_ddr3_rd_clk            (w_ddr3_rd_clk            ),
  .o_ddr3_rd_en             (w_ddr3_rd_en             ),
  .i_ddr3_rd_data           (w_ddr3_rd_data           ),
  .i_ddr3_rd_full           (w_ddr3_rd_full           ),
  .i_ddr3_rd_empty          (w_ddr3_rd_empty          ),
  .i_ddr3_rd_count          (w_ddr3_rd_count          ),
  .i_ddr3_rd_overflow       (w_ddr3_rd_overflow       ),
  .i_ddr3_rd_error          (w_ddr3_rd_error          ),

  //DMA Interface
  .i_idma_flush             (w_idma_flush             ),
  .i_idma_activate          (w_idma_activate          ),
  .o_idma_ready             (w_idma_ready             ),
  .i_idma_stb               (w_idma_stb               ),
  .o_idma_size              (w_idma_size              ),
  .o_idma_data              (w_idma_data              ),

  .i_odma_flush             (w_odma_flush             ),
  .o_odma_ready             (w_odma_ready             ),
  .i_odma_activate          (w_odma_activate          ),
  .i_odma_stb               (w_odma_stb               ),
  .o_odma_size              (w_odma_size              ),
  .i_odma_data              (w_odma_data              ),

  .o_debug                  (w_debug                  )
);


wishbone_master wm_sim (
  .clk                  (clk                  ),
  .rst                  (rst                  ),

  .i_ih_rst             (w_ih_reset           ),
  .i_ready              (w_in_ready           ),
  .i_command            (w_in_command         ),
  .i_address            (w_in_address         ),
  .i_data               (w_in_data            ),
  .i_data_count         (w_in_data_count      ),

  .i_out_ready          (w_out_ready          ),
  .o_en                 (w_out_en             ),
  .o_status             (w_out_status         ),
  .o_address            (w_out_address        ),
  .o_data               (w_out_data           ),
  .o_data_count         (w_out_data_count     ),
  .o_master_ready       (w_master_ready       ),

//  .o_per_we             (w_wbp_we               ),
//  .o_per_adr            (w_wbp_adr              ),
//  .o_per_dat            (w_wbp_dat_i            ),
  .i_per_dat            (r_per_data             ),
  .o_per_stb            (w_per_stb              ),
  .o_per_cyc            (w_per_cyc              ),
//  .o_per_msk            (w_wbp_msk              ),
//  .o_per_sel            (w_wbp_sel              ),
  .i_per_ack            (r_per_ack              ),
  .i_per_int            (1'b0                   ),  //Try this out later on

  //memory interconnect signals
//  .o_mem_we             (w_mem_we_o             ),
//  .o_mem_adr            (w_mem_adr_o            ),
//  .o_mem_dat            (w_mem_dat_o            ),
//  .i_mem_dat            (w_mem_dat_i            ),
//  .o_mem_stb            (w_mem_stb_o            ),
//  .o_mem_cyc            (w_mem_cyc_o            ),
//  .o_mem_sel            (w_mem_sel_o            ),
  .i_mem_ack            (1'b0                   ),  //Nothing should be on the memory bus
  .i_mem_int            (1'b0                   )

);

//DMA Sink and Source
adapter_dpb_ppfifo #(
  .MEM_DEPTH                  (CONTROL_FIFO_DEPTH     ),
  .DATA_WIDTH                 (32                     )
) dma_bram (
  .clk                        (clk                    ),
  .rst                        (rst                    ),
  .i_ppfifo_2_mem_en          (r_snk_en               ),
  .i_mem_2_ppfifo_stb         (r_mem_2_ppfifo_stb     ),
  .i_cancel_write_stb         (r_cancel_write_stb     ),
  .o_num_reads                (w_num_reads            ),
  .o_idle                     (w_read_idle            ),

  //User Memory Interface
  .i_bram_we                  (r_bram_we              ),
  .i_bram_addr                (w_bram_addr            ),
  .i_bram_din                 (r_bram_din             ),
  .o_bram_dout                (w_bram_dout            ),
  .o_bram_valid               (w_bram_valid           ),

  //Ping Pong FIFO Interface
  .ppfifo_clk                 (clk                    ),

  .i_write_ready              (w_dma_gen_rdy          ),
  .o_write_activate           (w_dma_gen_act          ),
  .i_write_size               (w_dma_gen_size         ),
  .o_write_stb                (w_dma_gen_stb          ),
  .o_write_data               (w_dma_gen_data         ),

  .i_read_ready               (w_dma_sink_rdy         ),
  .o_read_activate            (w_dma_sink_act         ),
  .i_read_size                (w_dma_sink_size        ),
  .o_read_stb                 (w_dma_sink_stb         ),
  .i_read_data                (w_dma_sink_data        )
);

localparam  CONTROL_BUFFER_SIZE = 2 ** CONTROL_FIFO_DEPTH;

assign i_ddr3_cmd_empty   = 1;
assign i_ddr3_cmd_full    = 0;

assign i_ddr3_wr_full     = 0;
assign i_ddr3_wr_empty    = 1;
assign i_ddr3_wr_count    = 0;
assign i_ddr3_wr_underrun = 0;
assign i_ddr3_wr_error    = 0;

assign i_ddr3_rd_data     = 32'h01234567;
assign i_ddr3_rd_full     = 1;
assign i_ddr3_rd_empty    = 0;
assign i_ddr3_rd_count    = 63;
assign i_ddr3_rd_overflow = 0;
assign i_ddr3_rd_error    = 0;

//Asynchronous Logic
assign  w_odma_flush      = 0;
assign  w_idma_flush      = 0;

assign  w_usr_interrupt_value = 32'h0;


//Synchronous Logic

always @ (posedge clk) begin
  if (rst) begin
    r_per_data    <=  0;
    r_per_ack     <=  0;
  end
  else begin
    if (!w_per_stb && r_per_ack) begin
      r_per_ack   <=  0;
    end
    if (w_per_cyc && w_per_stb && !r_per_ack) begin
      r_per_ack   <=  1;
      r_per_data  <=  r_per_data + 1;
    end
  end
end

wishbone_interconnect wi (
  .clk        (clk                  ),
  .rst        (r_rst                ),

  .i_m_we     (w_wbp_we             ),
  .i_m_cyc    (w_wbp_cyc            ),
  .i_m_stb    (w_wbp_stb            ),
  .o_m_ack    (w_wbp_ack            ),
  .i_m_dat    (w_wbp_dat_i          ),
  .o_m_dat    (w_wbp_dat_o          ),
  .i_m_adr    (w_wbp_adr            ),
  .o_m_int    (w_wbp_int            ),

  .o_s0_we    (w_wbs0_we            ),
  .o_s0_cyc   (w_wbs0_cyc           ),
  .o_s0_stb   (w_wbs0_stb           ),
  .i_s0_ack   (w_wbs0_ack           ),
  .o_s0_dat   (w_wbs0_dat_i         ),
  .i_s0_dat   (w_wbs0_dat_o         ),
  .o_s0_adr   (w_wbs0_adr           ),
  .i_s0_int   (w_wbs0_int           ),

  .o_s1_we    (w_wbs1_we            ),
  .o_s1_cyc   (w_wbs1_cyc           ),
  .o_s1_stb   (w_wbs1_stb           ),
  .i_s1_ack   (w_wbs1_ack           ),
  .o_s1_dat   (w_wbs1_dat_i         ),
  .i_s1_dat   (w_wbs1_dat_o         ),
  .o_s1_adr   (w_wbs1_adr           ),
  .i_s1_int   (w_wbs1_int           )
);

wishbone_mem_interconnect wmi (
  .clk        (clk                  ),
  .rst        (r_rst                ),

  //master
  .i_m_we     (w_mem_we_o           ),
  .i_m_cyc    (w_mem_cyc_o          ),
  .i_m_stb    (w_mem_stb_o          ),
  .i_m_sel    (w_mem_sel_o          ),
  .o_m_ack    (w_mem_ack_i          ),
  .i_m_dat    (w_mem_dat_o          ),
  .o_m_dat    (w_mem_dat_i          ),
  .i_m_adr    (w_mem_adr_o          ),
  .o_m_int    (w_mem_int_i          ),

  //slave 0
  .o_s0_we    (w_sm0_i_wbs_we       ),
  .o_s0_cyc   (w_sm0_i_wbs_cyc      ),
  .o_s0_stb   (w_sm0_i_wbs_stb      ),
  .o_s0_sel   (w_sm0_i_wbs_sel      ),
  .i_s0_ack   (w_sm0_o_wbs_ack      ),
  .o_s0_dat   (w_sm0_i_wbs_dat      ),
  .i_s0_dat   (w_sm0_o_wbs_dat      ),
  .o_s0_adr   (w_sm0_i_wbs_adr      ),
  .i_s0_int   (w_sm0_o_wbs_int      )
);

arbiter_2_masters arb0 (
  .clk        (clk                  ),
  .rst        (r_rst                ),

  //masters
  .i_m1_we    (mem_o_we             ),
  .i_m1_stb   (mem_o_stb            ),
  .i_m1_cyc   (mem_o_cyc            ),
  .i_m1_sel   (mem_o_sel            ),
  .i_m1_dat   (mem_o_dat            ),
  .i_m1_adr   (mem_o_adr            ),
  .o_m1_dat   (mem_i_dat            ),
  .o_m1_ack   (mem_i_ack            ),
  .o_m1_int   (mem_i_int            ),


  .i_m0_we    (w_sm0_i_wbs_we       ),
  .i_m0_stb   (w_sm0_i_wbs_stb      ),
  .i_m0_cyc   (w_sm0_i_wbs_cyc      ),
  .i_m0_sel   (w_sm0_i_wbs_sel      ),
  .i_m0_dat   (w_sm0_i_wbs_dat      ),
  .i_m0_adr   (w_sm0_i_wbs_adr      ),
  .o_m0_dat   (w_sm0_o_wbs_dat      ),
  .o_m0_ack   (w_sm0_o_wbs_ack      ),
  .o_m0_int   (w_sm0_o_wbs_int      ),

  //slave
  .o_s_we     (w_arb0_i_wbs_we      ),
  .o_s_stb    (w_arb0_i_wbs_stb     ),
  .o_s_cyc    (w_arb0_i_wbs_cyc     ),
  .o_s_sel    (w_arb0_i_wbs_sel     ),
  .o_s_dat    (w_arb0_i_wbs_dat     ),
  .o_s_adr    (w_arb0_i_wbs_adr     ),
  .i_s_dat    (w_arb0_o_wbs_dat     ),
  .i_s_ack    (w_arb0_o_wbs_ack     ),
  .i_s_int    (w_arb0_o_wbs_int     )
);

wb_bram #(
  .DATA_WIDTH (32                   ),
  .ADDR_WIDTH (10                   )
)bram(
  .clk        (clk                  ),
  .rst        (r_rst                ),

  .i_wbs_we   (w_arb0_i_wbs_we      ),
  .i_wbs_sel  (w_arb0_i_wbs_sel     ),
  .i_wbs_cyc  (w_arb0_i_wbs_cyc     ),
  .i_wbs_dat  (w_arb0_i_wbs_dat     ),
  .i_wbs_stb  (w_arb0_i_wbs_stb     ),
  .i_wbs_adr  (w_arb0_i_wbs_adr     ),
  .o_wbs_dat  (w_arb0_o_wbs_dat     ),
  .o_wbs_ack  (w_arb0_o_wbs_ack     ),
  .o_wbs_int  (w_arb0_o_wbs_int     )
);

//Disable Slave 0
assign  w_wbs0_int              = 0;
assign  w_wbs0_ack              = 0;
assign  w_wbs0_dat_o            = 0;
assign  device_interrupt        = w_wbp_int;

/*
  READ ME IF YOUR MODULE WILL INTERFACE WITH MEMORY

  If you want to talk to memory over the wishbone bus directly, your module must control the following signals:

  (Your module will be a wishbone master)
    mem_o_we
    mem_o_stb
    mem_o_cyc
    mem_o_sel
    mem_o_adr
    mem_o_dat
    mem_i_dat
    mem_i_ack
    mem_i_int

  Currently this bus is disabled so if will not interface with memory these signals can be left

  For a reference check out wb_sd_host

*/
assign  mem_o_we                = 0;
assign  mem_o_stb               = 0;
assign  mem_o_cyc               = 0;
assign  mem_o_sel               = 0;
assign  mem_o_adr               = 0;
assign  mem_o_dat               = 0;

//Submodules
//Asynchronous Logic
//Synchronous Logic
//Simulation Control
initial begin
  $dumpfile ("design.vcd");
  $dumpvars(0, tb_cocotb);
end

always @ (posedge clk) begin
  if (r_rst) begin
    r_pcie_reset_n  <=  0;
  end
  else begin
    r_pcie_reset_n  <=  1;
  end
end

endmodule
