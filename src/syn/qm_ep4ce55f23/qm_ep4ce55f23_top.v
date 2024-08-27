// Author: AlexG

module qm_ep4ce55f23_top (
  // Devboard
  input         CLK50M,
  input         nKEY0,                // SW1
  input         nKEY1,                // SW2
  output        nLED,                 // D5

  // SDRAM (32MB 4.194.304word x 4bank x 16bit)
  output        SDRAM_CLK,
  output        SDRAM_CKE,
  output [12:0] SDRAM_A,
  inout  [15:0] SDRAM_DQ,
  output [ 1:0] SDRAM_BA,
  output        SDRAM_LDQM,
  output        SDRAM_UDQM,
  output        SDRAM_nCS,
  output        SDRAM_nWE,
  output        SDRAM_nCAS,
  output        SDRAM_nRAS,

  // PS2
  input         PS2_CLK,
  input         PS2_DATA,

  // VGA/SCART
  output        VIDEO_HS,             // SCART -> Sync
  output        VIDEO_VS,
  output [3:0]  VIDEO_R,
  output [3:0]  VIDEO_G,
  output [3:0]  VIDEO_B,

  // AUDIO
  output        SOUND_L,
//output        SOUND_R,

  // SD CARD
  input         SD_MISO,
  output        SD_MOSI,
  output        SD_SCLK,
  output        SD_CS

  // UART1
//input         UART1_RXD,
//output        UART1_TXD,
//output        UART1_RTS
);


// de-activate unused SDRAM
//assign SDRAM_nCS = 1'b1;

// de-activate unused outputs
//assign nLED      = 1'b1;


// Clocks
wire        clk_master_s;
wire        clk_mem_s;

// Resets
wire        pll_locked_s;
wire        rst_s;
wire        por_s;

// MONITOR
wire [10:0] monitor_addr_s;
wire [ 7:0] monitor_data_s;

// ROM disk
wire [15:0] romdsk_addr_s;
wire [ 7:0] romdsk_data_s;

// RAM
wire [17:0] ram_addr_s;
wire [15:0] ram_data_di_s;
wire [ 7:0] ram_data_do_s;
wire        ram_we_s;
wire        ram_oe_s;
wire        ram_ce_s;

// AUDIO
wire        beep_s;
wire [ 7:0] beep_uns_s;

// PLL
pll1 pll (
  .inclk0         (CLK50M),         // 50.000 MHz
  .c0             (clk_master_s),   // 20.000 MHz             [20.000]
  .c1             (clk_mem_s),      // 80.00 MHz   0°
  .c2             (SDRAM_CLK),      // 80.00 MHz -90°
  .locked         (pll_locked_s)
);

// MONITOR
m2 monitor ( // 2kb
  .clk            (clk_master_s),
  .addr           (monitor_addr_s),
  .data           (monitor_data_s)
);

// ROM disk
rom_sdos romdsk ( // 8kb
  .clk            (clk_master_s),
  .addr           (romdsk_addr_s[12:0]),
  .data           (romdsk_data_s)
);

// Audio
dac audiol (
  .clk_i          (clk_master_s),
  .rst_i          (rst_s),
  .dac_i          (beep_uns_s),
  .dac_o          (SOUND_L)
);
assign beep_uns_s = beep_s ? 8'd16 : 8'd0;

ssdram256Mb #(
  .freq_g       (80)
)
ram (
  .clock_i      (clk_mem_s),
  .reset_i      (~pll_locked_s),
  .refresh_i    (1'b1),
  // Static RAM bus
  .addr_i       ({7'b0000000, ram_addr_s}),  // 256kb (max 32Mb)
  .data_i       (ram_data_do_s),
  .data_o       (ram_data_di_s),
  .cs_i         (ram_ce_s),
  .oe_i         (ram_oe_s),
  .we_i         (ram_we_s),
  // SD-RAM ports
  .mem_cke_o    (SDRAM_CKE),
  .mem_cs_n_o   (SDRAM_nCS),
  .mem_ras_n_o  (SDRAM_nRAS),
  .mem_cas_n_o  (SDRAM_nCAS),
  .mem_we_n_o   (SDRAM_nWE),
  .mem_udq_o    (SDRAM_UDQM),
  .mem_ldq_o    (SDRAM_LDQM),
  .mem_ba_o     (SDRAM_BA),
  .mem_addr_o   (SDRAM_A),
  .mem_data_io  (SDRAM_DQ)
);

// The Orion 128
orion the_orion (
  .clk_i          (clk_master_s),
  .por_i          (por_s),
  .rst_i          (rst_s),
  // IPL
//.iplrom_addr_o  (iplrom_addr_s),
//.iplrom_data_i  (iplrom_data_s),
  // MONITOR
  .monitor_addr_o (monitor_addr_s),
  .monitor_data_i (monitor_data_s),
  // ROM disk
  .romdsk_addr_o  (romdsk_addr_s),
  .romdsk_data_i  (romdsk_data_s),
  // RAM
  .ram_addr_o     (ram_addr_s),
  .ram_data_di_i  (ram_data_di_s),
  .ram_data_do_o  (ram_data_do_s),
  .ram_we_o       (ram_we_s),
  .ram_oe_o       (ram_oe_s),
  .ram_ce_o       (ram_ce_s),
  // PS2
  .ps2_clk_i      (PS2_CLK),
  .ps2_data_i     (PS2_DATA),
  // SD CARD
  .spi_cs_n_o     (SD_CS),
  .spi_sclk_o     (SD_SCLK),
  .spi_mosi_o     (SD_MOSI),
  .spi_miso_i     (SD_MISO),
  // RGB
  .hsync_n_o      (VIDEO_HS),
  .vsync_n_o      (VIDEO_VS),
  .rgb_r_o        (VIDEO_R),
  .rgb_g_o        (VIDEO_G),
  .rgb_b_o        (VIDEO_B),
  // AUDIO
  .beep_o         (beep_s),
  // LEDS
  .led0_n_o       (nLED),
  .led1_n_o       ()
);


// Power-on reset
reg [7:0] cnt_por_q;
wire por_async_s = ~pll_locked_s | ~nKEY0; //SW1
always @(posedge clk_master_s or posedge por_async_s)
begin
  if (por_async_s)
    cnt_por_q <= 8'h00;
  else if (cnt_por_q != 8'hFF)
    cnt_por_q <= cnt_por_q + 8'h01;
end
assign por_s = ~(cnt_por_q == 8'hFF);

// Reset
reg [7:0] cnt_rst_q;
wire rst_async_s = por_s | ~nKEY1; //SW2
always @(posedge clk_master_s or posedge rst_async_s)
begin
  if (rst_async_s)
    cnt_rst_q <= 8'h00;
  else if (cnt_rst_q != 8'hFF)
    cnt_rst_q <= cnt_rst_q + 8'h01;
end
assign rst_s = ~(cnt_rst_q == 8'hFF);

endmodule
